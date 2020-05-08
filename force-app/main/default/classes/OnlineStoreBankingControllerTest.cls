@isTest
public with sharing class OnlineStoreBankingControllerTest {
    @testSetup public static void setup() {
        List<User__c> users = new List<User__c>();
        for (Integer i = 0; i < 2; i++) {
            User__c user = OnlineStoreController.registerNewUser(new User__c(
                Name = 'Test User ' + i, 
                Email__c = 'test_user_' + i + '@example.com',
                Login__c = 'test_user_' + i
            ), 'test_pass_' + i);
            users.add(user);
        }

        List<BankCard__c> cards = new List<BankCard__c>();
        for (Integer i = 0; i < 10; i++) {
            cards.add(new BankCard__c(
                Number__c = '' + i + '91234123412349' + i,
                BankEmitter__c = 'U.S. Bank',
                Balance__c = (i + 1) * 5000,
                OwnerId__c = users[Math.mod(i, 2)].Id
            ));
        }
        insert cards;
    }

    @isTest static void testSetDefaultCard() {
        User__c user = [
            SELECT Id, Login__c, DefaultCardId__c, (
                SELECT Id, OwnerId__c
                FROM BankCards__r
            )
            FROM User__c
            WHERE Login__c = 'test_user_1'
        ];

        System.assertEquals(null, user.DefaultCardId__c);

        String cardId = user.BankCards__r[0].Id;
        String result = OnlineStoreBankingController.setDefaultCard(user.Id, cardId);

        System.assertEquals(cardId, result);

        user = [
            SELECT Id, Login__c, DefaultCardId__c
            FROM User__c
            WHERE Login__c = 'test_user_1'
        ];
        System.assertEquals(cardId, user.DefaultCardId__c);
    }

    @isTest static void testGetCards() {
        User__c user = [
            SELECT Id
            FROM User__c
            WHERE Login__c = 'test_user_1'
        ];
        List<BankCard__c> cards = OnlineStoreBankingController.getCards(user.Id);

        System.assertEquals(5, cards.size());
    }

    @isTest static void testSaveNewCard() {
        User__c user = [SELECT Id FROM User__c WHERE Login__c = 'test_user_1'];

        BankCard__c card = new BankCard__c(
            Number__c = '1234123412341234',
            BankEmitter__c = 'U.S. Bank',
            OwnerId__c = user.Id
        );

        try {
            OnlineStoreBankingController.saveNewCard(card);
            System.assertEquals(true, true);
        } catch (Exception e) {
            System.assertEquals(true, false);
        }

        System.assertNotEquals(null, card.Id);
    }

    @isTest static void testDeleteCard() {
        User__c user = [SELECT Id FROM User__c WHERE Login__c = 'test_user_1'];

        BankCard__c card = [SELECT Id FROM BankCard__c WHERE OwnerId__c = :user.Id LIMIT 1];

        Integer cardsCount = [SELECT COUNT() FROM BankCard__c WHERE OwnerId__c = :user.Id];

        OnlineStoreBankingController.deleteCard(card.Id);

        Integer cardsCountAfterDelete = [SELECT COUNT() FROM BankCard__c WHERE OwnerId__c = :user.Id];

        System.assertEquals(cardsCount - 1, cardsCountAfterDelete);
    }
}