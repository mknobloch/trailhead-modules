Account acct = new Account();
acct.name='Recruiting';
Database.insert(acct);
System.debug('A new account named ' + acct.name + ' was added ');
