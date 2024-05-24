import datetime,json
import traceback
import numpy as np
import logging
from KafkaBase import KafkaBase

RNG = np.random.default_rng()

class SensorDataGen(KafkaBase):
    def __init__(self, topic_out, maxsensors=10) -> None:        
        super().__init__(consumerid="SensroDataGen")
        self.machines = list(range(101, 100+maxsensors+1))
        self.bad_basetemp = 0 
        self.bad_baseamps = 0 
        self.topic_out = topic_out     
        
    def _getCensorObj(self, mid) -> object:
            temp = abs(RNG.normal(150, 10))
            amps = abs((temp / 10) + 8)
            pres = abs(RNG.normal(200, 5))            
            obj = {
                "temperature": float(round(temp,2)),
                "amps" : float(round(amps,2)),
                "pressure" : float(round(pres,2)),
                "timestamp" : '{:%Y-%m-%d %H:%M:%S}'.format(datetime.datetime.now()),
                "machineid": int(mid)
            }
            return(obj)
        
    def Run(self, badData=False):
        self._set_producer()
        try:
            if badData:                
                self._generateBadData()
            else:
                self._generateData()

        except Exception as e:
            logging.exception(traceback.format_exc())
        finally:
            self._close_producer()


    def _generateData(self) ->None:        
        for mid in self.machines:
            obj = self._getCensorObj(mid)
            logging.info(str(obj))
            self.producer.produce(self.topic_out, json.dumps(obj), mid.to_bytes(1,'big', signed=False), callback=KafkaBase.delivery_callback)
    
    def _generateBadData(self, badmid=105) ->None:
        for mid in self.machines:
            obj = self._getCensorObj(mid)                        
            if (mid == badmid):
                temp = 0.0
                if self.bad_basetemp == 0:
                    self.bad_basetemp = abs(RNG.normal(160, 10))                                
                if self.bad_basetemp > 170:
                    temp = self.bad_basetemp + RNG.normal(0, 0.5)
                else:
                    temp = self.bad_basetemp + abs(RNG.normal(3, 1))
                obj["temperature"] = float(round(temp,2))
                self.bad_basetemp = temp
            
                amps = 0.0
                if self.bad_baseamps == 0:
                    self.bad_baseamps = abs(RNG.normal(27, 3))
                if self.bad_baseamps > 30:
                    diff = RNG.normal(0, 0.5)
                    amps = self.bad_baseamps + diff
                    logging.info(diff)
                else:
                    amps = self.bad_baseamps + abs(RNG.normal(2, 0.5))
                obj["amps"] = float(round(amps,2))
                self.bad_baseamps = amps
                
                logging.info(str(obj))                
            self.producer.produce(self.topic_out, json.dumps(obj), mid.to_bytes(1,'big', signed=False), callback=KafkaBase.delivery_callback)
    


    