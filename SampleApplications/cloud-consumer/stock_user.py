
class user:
    def __init__(self, userid) -> None:
        self.userid = userid
        self.accountValue = 0
        self.totalTrades = 0
        self.failedTrades = 0
        self.openTrades = 0
        self.accounts = []
    
    def processSell(self,price, account):
        self.totalTrades+=1
        self.openTrades-=1
        self.accountValue += price        
        self.updateAccounts(account)
    
    def processBuy(self, price, account):
        if (price < self.accountValue):
            self.totalTrades+=1
            self.openTrades+=1
            self.accountValue-=price
            self.updateAccounts(account)
            return True
        else:
            self.failedTrades+=1            
            return False

    def updateAccounts(self, account):
        if account not in self.accounts:
            self.accounts.append(account)

    def getSummary(self):
        ret_obj = {
            "userid" : self.userid,
            "accountBalance" : self.accountValue,
            "failedTrades" : self.failedTrades,
            "accounts" : self.accounts
        }
        return ret_obj
         
