#!/usr/bin/python3
import logging
from stockTracker import stockTracker
TRACKER = stockTracker(consumerid="trackerweb_srvc")


# Start script
if __name__ == "__main__":
    try:
        TRACKER.read_topic(maxevents=200)
    except Exception as e:
        logging.exception(e)
    finally:
        logging.info("Handled {} events".format(TRACKER.TotalEvents))