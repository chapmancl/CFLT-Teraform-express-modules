#!/usr/bin/python3

import json
import logging
from stockTracker import stockTracker

def lambda_handler(event, context):    
    total_events = 0
    version = "1.0.1"
    try:
        TRACKER = stockTracker(consumerid="tracker_lambda_awstrigger")

        if ("eventSource" in event and event["eventSource"] == "SelfManagedKafka"):
          # triggered by kafka            
            try:
                topicevents = []
                for k in event["records"].keys():
                    topicevents.append(event["records"][k][:])

                TRACKER.process_batch(topicevents)
                total_events = TRACKER.TotalEvents
            except Exception as e:
                logging.exception(e)
            finally:
                logging.info(f"Trigger complete with {total_events}")
        else:
            # API Call
            max = 100
            if "max" in event.keys():
                max = event['max']
            try:
                TRACKER.read_topic(maxevents=max)
                total_events = TRACKER.TotalEvents
            except Exception as e:
                logging.exception(e)
            finally:
                logging.info(f"API complete with {total_events}")
    
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "result ": f"Handled {total_events} events",
                "version" : version
            })
        }
    except Exception as e:
        logging.exception(e)