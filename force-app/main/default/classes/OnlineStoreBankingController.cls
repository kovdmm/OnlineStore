public with sharing class OnlineStoreBankingController {
    @AuraEnabled
    public static String setDefaultCard(String userId, String cardId) {
        User__c user = [SELECT Id, DefaultCardId__c FROM User__c WHERE Id = :userId LIMIT 1];
        BankCard__c card = [SELECT Id, OwnerId__c FROM BankCard__c WHERE Id = :cardId LIMIT 1];

        if (user.Id != card.OwnerId__c) return '';

        user.DefaultCardId__c = cardId;
        update user;

        return cardId;
    }
    
    /*
    TODO: Delete
    private static BankCard__c getCard(String cardId) {
        return [
            SELECT Id, Number__c, BankEmitter__c, Balance__c, OwnerId__c 
            FROM BankCard__c 
            WHERE Id = :cardId 
            LIMIT 1
        ];
    }
    */

    @AuraEnabled
    public static List<BankCard__c> getCards(String userId) {
        return [
            SELECT Id, Number__c, BankEmitter__c, Balance__c, OwnerId__c 
            FROM BankCard__c 
            WHERE OwnerId__c = :userId
        ];
    }

    @AuraEnabled
    public static BankCard__c saveNewCard(BankCard__c newCard) {
        // Emulation only 
        newCard.Balance__c = genRandomDoubleInRange(2000, 3000); // USD
        return saveCard(newCard);
    }

    private static Double genRandomDoubleInRange(Integer min, Integer max) {
        return (Double)(min + Math.random() * (max - min));
    }

    private static BankCard__c saveCard(BankCard__c card) {
        upsert card;
        return card;
    }

    @AuraEnabled
    public static Boolean deleteCard(String cardId) {
        BankCard__c card = [SELECT Id FROM BankCard__c WHERE Id = :cardId];
        delete card;
        return true;
    }
}