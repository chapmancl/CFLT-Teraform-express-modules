#!/usr/bin/python3

from stockTracker import stockTracker
import os
import logging
from flask import Flask
app = Flask(__name__)
TRACKER = stockTracker(consumerid="trackerweb_html")

@app.route("/reset")
def reset():
    try:
        TRACKER.reset()
    except Exception as e:
        logging.exception(e)    
    return "All users reset<br/><a href=\"/run\">Click here to run</a>"

# Define main script
@app.route("/run")
def main():    
    str_tbl = "<table><tr><th>User ID</th> <th>Account Value</th> <th>Successful Trades</th> <th>Failed Trades</th></tr>\r\n"
    try:
        TRACKER.read_topic()
        for uid in sorted(TRACKER.USERS.keys()):
            user = TRACKER.USERS[uid]
            str_tbl += "<tr>"
            str_tbl += "<th>{}</th><td>{}</td><td>{}</td><td>{}</td>".format(uid, user.accountValue, user.totalTrades, user.failedTrades)
            str_tbl += "</tr>\r\n"
        str_tbl+="</table>"
        
    except Exception as e:
        logging.exception(e)
    finally:
        logging.info("Handled {} events".format(TRACKER.TotalEvents))
        str_tbl += "<br/><a href=\"/run\">Update</a>"
        str_tbl += "<br/><a href=\"/reset\">Reset</a>"
        return str_tbl


@app.route("/")
def index():
    str_ret = "<h1>I'm alive v2.0</h1>"
    str_ret += "<br/><a href=\"/run\">Click here to run</a>"
    str_ret += "<br/><a href=\"/reset\">Reset</a>"
    return str_ret

# Start script
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
