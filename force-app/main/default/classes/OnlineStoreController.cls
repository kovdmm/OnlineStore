public with sharing class OnlineStoreController {
    @AuraEnabled
    public static User__c getUserByToken(String token) {
        List<User__c> users = [
            SELECT Id, Name, Login__c, Email__c, Token__c,
                Street__c, City__c, Country__c, Province__c, PostalCode__c,
                DefaultCardId__c, DefaultCardId__r.Balance__c
            FROM User__c
            WHERE Token__c = :token
        ];

        // Wrong data are not fatal
        // return users.size() > 0 ? users[0] : new User__c(); 
        if (users.size() > 0) {
            return users[0];
        } else {
            return new User__c();
        }
    }

    @AuraEnabled
    public static User__c authUser(String login, String password) {
        String passHash = hashPassword(password);

        List<User__c> users = [
            SELECT Id, Name, Login__c, Email__c, Token__c,
                Street__c, City__c, Country__c, Province__c, PostalCode__c,
                DefaultCardId__c, DefaultCardId__r.Balance__c
            FROM User__c
            WHERE Login__c = :login AND PassHash__c = :passHash
        ];

        // Wrong data are not fatal
        //return users.size() > 0 ? updateUserToken(users[0]) : new User__c();
        if (users.size() > 0) {
            return updateUserToken(users[0]);
        } else {
            return new User__c();
        }
    }

    public static User__c getUser(String userId) {
        return [
            SELECT Id, Name, Login__c, Email__c, Token__c,
                Street__c, City__c, Country__c, Province__c, PostalCode__c,
                DefaultCardId__c, DefaultCardId__r.Balance__c
            FROM User__c
            WHERE Id = :userId
        ];
    }

    public static String hashPassword(String password) {
        return SHA256(password);
    }

    private static User__c updateUserToken(User__c usr) {
        usr.Token__c = generateToken();
        update usr;
        return usr;
    }

    public static String generateToken() {
        return SHA256(String.valueOf(Crypto.getRandomInteger()));
    }

    private static String SHA256(String value) {
        Blob digest = Crypto.generateDigest('SHA256', Blob.valueOf(value));
        return EncodingUtil.base64Encode(digest);
    }

    @AuraEnabled
    public static User__c registerNewUser(User__c user, String password) {
        user.PassHash__c = hashPassword(password);
        user.Token__c = generateToken();
        insert user;

        sendEmailNotification(
            user.Email__c, 
            'OnlineStore Registration',
            'Congratulations! You`ve successfully register in OnlineStore with login <b>' + user.Login__c + '</b>' + 
                ' and password <b>' + password + '</b>.'
        );

        return user;
    }

    public static Boolean sendEmailNotification(String to, String subject, String message) {
        // TODO: implement sending email
        return true;
    }

    @AuraEnabled
    public static User__c updateUser(User__c user) {
        update user;
        return user;
    }

    @AuraEnabled
    public static String updateUserPassword(String userId, String password) {
        User__c user = [SELECT Id, PassHash__c FROM User__c WHERE Id = :userId];
        String passHash = hashPassword(password);
       
        user.PassHash__c = passHash;
        update user;

        return passHash;
    }

    @AuraEnabled
    public static Integer getCartItemsCount(String userId) {
        return OnlineStoreCartController.getCartItemsCount(userId);
    }
}