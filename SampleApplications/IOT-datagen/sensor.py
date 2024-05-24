
class sensor:
    def __init__(self, machineid) -> None:
        self.machineid = machineid
        self.count = 0
        self.AVGtemperature = 0.0
        self.AVGpressure = 0.0
        self.AVGamps = 0.0        
        self.temperature = 0.0
        self.pressure = 0.0
        self.amps = 0.0
        self.timestamp = ""
        self.hasThresholdAlert = False
        self.AlertMeasures = []
    
    def checkAlertlevels(self):
        if self.temperature > 170:
            self.hasThresholdAlert = True
            self.AlertMeasures.append("Temperature: {:0.2f}, Avg Temp: {:0.2f}".format(self.temperature, self.AVGtemperature))
        if self.amps > 27:
            self.hasThresholdAlert = True
            self.AlertMeasures.append("Amps: {:0.2f}, Avg Amps: {:0.2f}".format(self.amps, self.AVGamps))
        if self.pressure > 210:
            self.hasThresholdAlert = True
            self.AlertMeasures.append("Pressure: {:0.2f}, Avg Temp: {:0.2f}".format(self.pressure, self.AVGpressure))

    def tempColor(self, val):
        color = "green"
        if val > 170:
            color = "red"
        elif val > 155:
            color = "yellow"
        return color
    
    def ampColor(self, val):
        color = "green"
        if val > 27:
            color = "red"
        elif val > 24:
            color = "yellow"
        return color
    
    def pressureColor(self, val):
        color = "green"
        if val > 210:
            color = "red"
        elif val > 205:
            color = "yellow"
        return color
    
    def getHTML(self):
        str_ret = ""
        cell = "<td style=\"background-color:{};\">{:0.2f}</td>"
        str_ret += cell.format(self.tempColor(self.temperature), self.temperature)
        str_ret += cell.format(self.ampColor(self.amps), self.amps)
        str_ret += cell.format(self.pressureColor(self.pressure), self.pressure)
        str_ret += cell.format(self.tempColor(self.AVGtemperature), self.AVGtemperature)
        str_ret += cell.format(self.ampColor(self.AVGamps), self.AVGamps)
        str_ret += cell.format(self.pressureColor(self.AVGpressure), self.AVGpressure)
        str_ret += "<td>{}</td>".format(self.timestamp)
        return (str_ret)

    def update(self, obj):
        self.temperature =  obj.temperature
        self.pressure =     obj.pressure
        self.amps =         obj.amps        
        self.timestamp =    obj.timestamp
        if self.count == 0:
            self.AVGtemperature = obj.temperature
            self.AVGpressure =    obj.pressure
            self.AVGamps =        obj.amps
        else:
            newcount = self.count+1
            self.AVGtemperature = ((self.AVGtemperature * self.count) + obj.temperature) / newcount
            self.AVGpressure = ((self.AVGpressure * self.count) + obj.pressure) / newcount
            self.AVGamps =  ((self.AVGamps * self.count) + obj.amps) / newcount
        self.count += 1
        self.checkAlertlevels()

    def getSummary(self):
        ret_obj = {
                "temperature": self.temperature,
                "amps" : self.amps,
                "pressure" : self.pressure,
                "timestamp" : self.timestamp,
                "machineid": self.machineid
            }
        return ret_obj
    
    def getAlerts(self):
        ret_obj = {
                "timestamp" : self.timestamp[:10],
                "machineid": self.machineid,
                "Alerts":self.AlertMeasures
            }
        return ret_obj
         
