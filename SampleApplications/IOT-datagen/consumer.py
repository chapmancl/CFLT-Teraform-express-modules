#!/usr/bin/python3
from KafkaBase import KafkaBase
from confluent_kafka import KafkaException
from types import SimpleNamespace
import sys, os, json

def read_topic(topicname):    
    # Subscribe to topicss
    kafka = KafkaBase()
    consumer = kafka.get_consumer(topicname)
    # Read messages from Kafka, print to stdout
    try:
        while True:
            msg = consumer.poll(timeout=1.0)
            if msg is None:
                continue
            if msg.error():
                raise KafkaException(msg.error())
            else:
                # Proper message 
                obj = json.loads(msg.value().decode("utf-8"), object_hook=lambda d: SimpleNamespace(**d))    
                print(str(obj))
                
                # Store the offset associated with msg to a local cache.
                # Stored offsets are committed to Kafka by a background thread every 'auto.commit.interval.ms'.
                # Explicitly storing offsets after processing gives at-least once semantics.
                consumer.store_offsets(msg)

    except KeyboardInterrupt:
        sys.stderr.write('%% Aborted by user\n')

    finally:
        # Close down consumer to commit final offsets.
        consumer.close()

if __name__ == '__main__':
    print(sys.argv[1])
    if (len(sys.argv) > 1):
        read_topic([sys.argv[1]])    
    else:
        TOPIC_DATAGEN_IN = os.environ["CC_TOPIC_IN"]
        read_topic([TOPIC_DATAGEN_IN]) 

