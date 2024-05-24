#!/usr/bin/python3
from sensorDataGen import SensorDataGen
import sys, time, os, traceback
TOPIC_DATAGEN_IN = os.environ["CC_TOPIC_IN"] 

def datagen(bad=False):
    print("start")    
    try:
        generator = SensorDataGen(TOPIC_DATAGEN_IN)
        while True:        
            generator.Run(bad)
            time.sleep(5)

    except KeyboardInterrupt:
        sys.stderr.write('%% Aborted by user\n')
    except Exception as e:
        print(traceback.format_exc())
    finally:
        # Close down consumer to commit final offsets.
        pass


if __name__ == '__main__':
    bad = False
    if (len(sys.argv) > 1 and int(sys.argv[1]) == 1):
        bad = True
        print("bad machine")
    datagen(bad)

