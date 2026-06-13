Candidate__c c = new Candidate__c(
    First_Name__c = 'Gina',
    Last_Name__c = 'Simmons',
    Email__c = 'gsimmons@test.com'
);
insert c;
System.debug('Created Candidate. Trigger should have created Contact: Gina Simmons');
