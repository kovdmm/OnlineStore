public with sharing class OnlineStoreBankingController {
    public inherited sharing class BankingException extends Exception {}

    @AuraEnabled
    public static String setDefaultCard(String userId, String cardId) {
        User__c user = OnlineStoreController.getUser(userId);
        BankCard__c card = getCard(cardId);

        if (user.Id != card.OwnerId__c) return '';

        user.DefaultCardId__c = cardId;
        update user;

        return cardId;
    }

    public static BankCard__c getCard(String cardId) {
        return [
            SELECT Id, Number__c, BankEmitter__c, Balance__c, OwnerId__c 
            FROM BankCard__c 
            WHERE Id = :cardId
        ];
    }

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

    public static Boolean widthdrawFromCard(String userId, Double amount) {
        User__c user = OnlineStoreController.getUser(userId);

        if (user.DefaultCardId__c == null) throw new BankingException('You didn\'t set default card.');

        BankCard__c card = user.DefaultCardId__r;

        if (card.Balance__c < amount) throw new BankingException('You have no enough money.');

        card.Balance__c -= amount;
        update card;
        return true;
    }
}