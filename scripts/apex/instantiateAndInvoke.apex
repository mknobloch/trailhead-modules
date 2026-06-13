//From the BankAcct class, instantiate an object named chkAcct
BankAcct chkAcct = new BankAcct();
//Set the accttype attribute of the chkAcct object to Checking
chkAcct.accttype = 'Checking';
//Set the acctName attribute of the chkAcct object to D.Castillo-Chk
chkAcct.acctName = 'D.Castillo-Chk';
//Invoke the makeDeposit method with 150 as the argument
chkAcct.makeDeposit(150);
System.debug(chkAcct.getBalance());
