//From the BankAcct class, instantiate an object named chkAcct
BankAcct chkAcct = new BankAcct();
//Set the accttype attribute of the chkAcct object to Checking
chkAcct.accttype = 'Checking';
//Set the acctName attribute of the chkAcct object to D.Castillo-Chk
chkAcct.acctName = 'D.Castillo-Chk ';
//Invoke the makeDeposit method with 150 as the argument
chkAcct.makeDeposit(150);
//From the BankAcct class, instantiate an object named savAcct
BankAcct savAcct = new BankAcct();
//Set the accttype attribute of the savAcct object to Savings
savAcct.accttype = 'Savings';
//Set the acctName attribute of the savAcct object to D.Castillo-Sav
savAcct.acctName = 'D.Castillo–Sav';
//Invoke the makeDeposit method with 220 as the argument
savAcct.makeDeposit(220);
//From the List class, instantiate a BankAcct List object named bankAccts
List<BankAcct> bankAccts = new List<BankAcct>();
System.debug('The BankAcct List has ' + bankAccts.size() + ' bank accounts.');
//Add the chkAcct object to the bankAccts list
bankAccts.add(chkAcct);
//Add the savAcct object to the bankAccts list
bankAccts.add(savAcct);
System.debug('The BankAcct List has ' + bankAccts.size() + ' bank accounts.');
System.debug('Here is the list: ' + bankAccts);
