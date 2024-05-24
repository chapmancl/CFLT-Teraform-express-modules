
from KafkaBase import KafkaBase
from stock_user import user
import os,base64,traceback
import json
from types import SimpleNamespace
import logging

# Retrieve Job-defined env vars
TOPIC_ORDERS_IN = "topic_stocktrades"
TOPIC_FAILED_OUT = os.environ["CC_TOPIC_OUT"]
TOPIC_ACCOUNTS_OUT = os.environ["CC_ACCOUNT_OUT"]


class stockTracker(KafkaBase):
    def __init__(self, maxevents=100, consumerid="trackerweb_container") -> None:
        super().__init__(consumerid=consumerid)
        self.USERS = {}
        self.MAXEVENTS = maxevents
        self.TotalEvents = 0
        
    def reset(self):
        self.USERS = None
        self.USERS = {}
    

    def read_topic(self, topicname=[TOPIC_ORDERS_IN], maxevents=100):
        self.MAXEVENTS = maxevents        
        consumer = self.get_consumer(topicname)
        
        # Read messages from Kafka
        count =0
        try:
            while True:
                msg = consumer.poll(timeout=1.0)
                if msg is None:
                    continue
                if msg.error():
                    logging.exception(msg.error())
                else:
                    trade = json.loads(msg.value(), object_hook=lambda d: SimpleNamespace(**d))    
                    self.ProcessClaim(trade)
                    count+=1
                    self.TotalEvents +=1

                    # Store the offset associated with msg to a local cache.
                    # Stored offsets are committed to Kafka by a background thread every 'auto.commit.interval.ms'.
                    # Explicitly storing offsets after processing gives at-least once semantics.
                    consumer.store_offsets(msg)

                    if count>=self.MAXEVENTS:
                        break
                    elif (count % 100) == 0:
                        logging.info("pocessed {} events".format(count))                    

        except Exception as e:
            logging.exception(traceback.format_exc())
        finally:
            # Block until the messages are sent.
            logging.debug("blocking...")
            if self.producer is not None:
                self.producer.poll(10000)
                self.producer.flush()
            # Close down consumer to commit final offsets.        
            consumer.close()


    def process_batch(self, data):
        # Read messages from Kafka consumer (AWS trigger)
        logging.info("process batch")
        count =0
        try:
            for part in data:
                for msg in part:
                    if msg is None:
                        continue
                    else:
                        rec=base64.b64decode(msg['value'])
                        trade=json.loads(rec, object_hook=lambda d: SimpleNamespace(**d))
                        self.ProcessClaim(trade)
                        count+=1
                        self.TotalEvents +=1
                        if (count % 100) == 0:
                            logging.info("pocessed {} events".format(count))                    

        except Exception as e:
            logging.exception(traceback.format_exc())
        finally:
            # Block until the messages are sent.
            logging.debug("blocking...")
            self._close_producer()
            
    def ProcessClaim(self, trade):
        self._set_producer()
        try:
            userid = trade.userid
            if not userid in self.USERS.keys():
                self.USERS[userid] = user(userid)
            
            if trade.side == "BUY":
                if not self.USERS[userid].processBuy(trade.price, trade.account):
                    # send to failed topic
                    obj = {
                        "account": trade.account,
                        "price" : trade.price,
                        "userid" : userid,
                        "symbol" : trade.symbol
                    }
                    self.producer.produce(TOPIC_FAILED_OUT, json.dumps(obj), userid, callback=KafkaBase.delivery_callback)

            elif trade.side == "SELL":
                self.USERS[userid].processSell(trade.price, trade.account)
            else:
                logging.warning("unknown transaction with user %s in acc %s"%(userid,  trade.account))

            self.producer.produce(TOPIC_ACCOUNTS_OUT, json.dumps(self.USERS[userid].getSummary()), userid, callback=KafkaBase.delivery_callback)
            
        except AttributeError as attr:
            logging.error(attr)
            

    