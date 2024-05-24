#!/usr/bin/python3

from sensorReader import sensorRead
import os, traceback
import logging
from flask import Flask
app = Flask(__name__)

TOPIC_ORDERS_IN = os.environ["CC_TOPIC_IN"]  #"sensordemoapp_Sensor_incoming"
SENS = sensorRead([TOPIC_ORDERS_IN])

@app.route("/reset")
def reset():
    try:
        SENS.reset()
    except Exception as e:
        logging.exception(traceback.format_exc())   
    return "All machines reset<br/><a href=\"/run\">Click here to run</a>"

# Define main script
@app.route("/run")
def main():    
    str_tbl = "<table><tr><th>Machine ID</th><th>Curr Temp</th> <th>Curr Amps</th> <th>Curr Pressure</th> <th>Avg Temp</th> <th>Avg Amps</th> <th>Avg Pressure</th><th>last reading</th></tr>\r\n"
    try:
        Machines = SENS.read_topic()
        for uid in Machines:
            macsensor = SENS.MACHINES[uid]
            str_tbl += "<tr>"
            str_tbl += "<th>{}</th>".format(uid)
            str_tbl += macsensor.getHTML()
            str_tbl += "</tr>\r\n"
        str_tbl+="</table>"
        str_tbl += "<br/><a href=\"/run\">Update</a>"
        str_tbl += "<br/><a href=\"/reset\">Reset</a>"
        
    except Exception as e:
        logging.exception(traceback.format_exc())
    finally:
        logging.info("Handled {} events".format(SENS.TotalEvents))
        return str_tbl


@app.route("/")
def index():
    str_ret = "<h1>I'm alive v1.0</h1>"
    str_ret += "<br/><a href=\"/run\">Click here to run</a>"
    str_ret += "<br/><a href=\"/reset\">Reset</a>"
    return str_ret
    

# Start script
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
