from KafkaBase import KafkaBase
from sensor import sensor
from types import SimpleNamespace
import json, traceback
import logging

class sensorAnalyzer(KafkaBase):
    def __init__(self, topic, out_topic=None) -> None:
        super().__init__(consumerid="sensor-analyzer")
        self.MACHINES = {}
        self.topicname = topic
        self.outtopic = out_topic
        self.TotalEvents = 0
        
    def reset(self):
        self.MACHINES = None
        self.MACHINES = {}

    def machineids(self):
        return (sorted(self.MACHINES.keys()))

    def read_topic(self, maxevents=10):    
        count = 0
        machineids = []
        machineAlertids = {}        
        eventlimit = maxevents
        try:            
            logging.info("begin consume")
            consumer = self.get_consumer([self.topicname])
            # Read messages from Kafka
            while count < eventlimit:
                msg = consumer.poll(timeout=1.0)                
                if msg is None:
                    continue
                if msg.error():
                    logging.exception(msg.error())
                else:
                    # Proper message 
                    obj = json.loads(msg.value().decode("utf-8"), object_hook=lambda d: SimpleNamespace(**d))
                    
                    if not obj.machineid in machineids:
                        macobj = sensor(obj.machineid)
                        self.MACHINES[obj.machineid] = macobj
                        machineids.append(obj.machineid)
                    
                    arrmac = self.MACHINES[obj.machineid]
                    arrmac.update(obj)
                    self.MACHINES[obj.machineid] = arrmac
                    consumer.store_offsets(msg)
                    if arrmac.hasThresholdAlert:
                        machineAlertids[obj.machineid] = arrmac
                    
                count+=1
                self.TotalEvents +=1
                # read until we have a min number of machines to display
                if count >= eventlimit and len(machineids) < 10:
                    eventlimit += 10                    

            logging.info("begin producing")
            self._set_producer()
            for macid in machineAlertids.keys():
                alermac = machineAlertids[macid]
                if alermac.hasThresholdAlert and self.outtopic is not None:
                    logging.info(alermac.getAlerts())
                    self.producer.produce(self.outtopic, json.dumps(alermac.getAlerts()), alermac.machineid.to_bytes(1,'big', signed=False), callback=KafkaBase.delivery_callback)


        except RuntimeError as re:
            logging.exception(re)
        except Exception as e:
            logging.exception(traceback.format_exc())
        finally:
            consumer.close()
            self._close_producer()