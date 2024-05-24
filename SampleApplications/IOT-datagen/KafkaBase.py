from pyconf import conf 
import os, logging
from confluent_kafka import Consumer,Producer, KafkaException
from AWS_SSM import access_secret_version
#from GCP_SSM import access_secret_version

class KafkaBase:
    def __init__(self, consumerid="kafkabase_consumer") -> None:
        self.TotalEvents = 0
        self.producer = None
        self.consumerid = consumerid
        self._conf = {}
        self._set_conf()

    def _set_conf(self):
        credPath = os.environ["CC_CRED_PATH"]
        ssm = access_secret_version(credPath)
        conf["bootstrap.servers"] = ssm["brokerurl"]
        conf["sasl.username"] = ssm["kafka_api_key"]
        conf["sasl.password"] = ssm["kafka_api_secret"]
        self._conf = conf
    
    def _set_producer(self, ) -> None:
        if self.producer is None:
            self._conf["client.id"] = self.consumerid
            self.producer = Producer(self._conf)

    def _close_producer(self)-> None:
        # Block until the messages are sent.
        logging.debug("blocking...")
        if self.producer is not None:
            self.producer.poll(10000)
            self.producer.flush()
    
    def get_consumer(self, topicname) -> object:
        self._conf["client.id"] = self.consumerid
        self._conf["group.id"] = self.consumerid        
        consumer = Consumer(self._conf)
        # Subscribe to topicss        
        consumer.subscribe(topicname, on_assign=KafkaBase.print_assignment,
                           on_revoke=KafkaBase.on_revoke,
                           on_lost=KafkaBase.on_lost
                           )
        return(consumer)

    def on_revoke(consumer, partitions):
        logging.debug("revoked: {}".format(partitions))
    def on_lost(consumer, partitions):
        logging.debug("lost: {}".format(partitions))    
    def print_assignment(consumer, partitions):
        logging.debug('Assignment: {}'.format(partitions))

    # Optional per-message delivery callback (triggered by poll() or flush())
    # when a message has been successfully delivered or permanently
    # failed delivery (after retries).
    def delivery_callback(err, msg):    
        if err:
            logging.error('ERROR: Message failed delivery to topic{}: {}'.format(msg.topic(),err))
        else:
            logging.debug("Produced event to topic {topic}: key = {key:12} value = {value:12}".format(
                topic=msg.topic(), key=msg.key().decode('utf-8'), value=msg.value().decode('utf-8')))