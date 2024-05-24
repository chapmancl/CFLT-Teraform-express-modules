#!/usr/bin/python3
from sensorAnalyzer import sensorAnalyzer
import sys, os, time
import logging
TOPIC_DATAGEN_IN = os.environ["CC_TOPIC_IN"] 
TOPIC_DATAGEN_OUT = os.environ["CC_TOPIC_OUT"] 

# Start script
if __name__ == "__main__":    
    try:
        sensor = sensorAnalyzer(TOPIC_DATAGEN_IN, TOPIC_DATAGEN_OUT)
        while True:        
            sensor.read_topic()
            time.sleep(5)

    except KeyboardInterrupt:
        logging.error('%% Aborted by user\n')
    except Exception as e:
        logging.exception(e)
    finally:
        logging.info("Handled {} events".format(sensor.TotalEvents))