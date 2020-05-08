User__c user = [SELECT Id, Login__c FROM User__c WHERE Login__c = 'kovdmm' LIMIT 1];

BankCard__c card = new BankCard__c();

card.Number__c = '1234567890123456';
card.BankEmitter__c = 'U.S. Bank';
card.OwnerId__c = user.Id;
card.Balance__c = 75000.00;

insert card;