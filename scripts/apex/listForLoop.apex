BankAcct chkAcct = new BankAcct();
chkAcct.accttype = 'Checking';
chkAcct.acctName = 'D.Castillo-Chk ';
chkAcct.makeDeposit(150);
BankAcct savAcct = new BankAcct();
savAcct.accttype = 'Savings';
savAcct.acctName = 'D.Castillo–Sav';
savAcct.makeDeposit(220);
List<BankAcct> bankAccts = new List<BankAcct>();
bankAccts.add(chkAcct);
bankAccts.add(savAcct);
for (BankAcct tempacct:bankAccts){
    system.debug(tempacct.acctName + ' is a ' + tempacct.accttype +
    ' account with a balance of $'+ tempacct.getBalance());
}
