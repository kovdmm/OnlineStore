insert new User__c(
    Name = 'Dmitry Kovalev', 
    Email__c = 'kov.dmm@gmail.com',
    Login__c = 'kovdmm',
    PassHash__c = OnlineStoreController.hashPassword('password')
);