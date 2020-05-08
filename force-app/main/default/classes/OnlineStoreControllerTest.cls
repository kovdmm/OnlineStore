@isTest
public with sharing class OnlineStoreControllerTest {
    static Integer usersAmount = 10;

    @testSetup static void setup() {
        List<User__c> testUsers = new List<User__c>();

        for (Integer i = 0; i < usersAmount; i++) {
            User__c testUser = new User__c(
                Name = 'Test User ' + i, 
                Email__c = 'test_user_' + i + '@example.com',
                Login__c = 'test_user_' + i,
                PassHash__c = OnlineStoreController.hashPassword('test_pass_' + i)
            );

            testUsers.add(testUser);
        }

        insert testUsers;
    }

    @isTest static void testAuthUser() {
        User__c usr = OnlineStoreController.authUser('test_user_1', 'test_pass_1');
        
        System.assertNotEquals(null, usr.Token__c);
        System.assertEquals('Test User 1', usr.Name);
    }

    @isTest static void testAuthUserWrongPass() {
        User__c usr = OnlineStoreController.authUser('test_user_1', 'anyotherpass');
    
        System.assertEquals(null, usr.Name);
    }

    @isTest static void testGetUserByToken() {
        User__c usr = OnlineStoreController.authUser('test_user_2', 'test_pass_2');
        String usrToken = usr.Token__c;

        User__c testUser = OnlineStoreController.getUserByToken(usrToken);
        System.assertEquals('Test User 2', testUser.Name);
    }

    @isTest static void testGetUserByInvalidToken() {
        User__c testUser = OnlineStoreController.getUserByToken('anyothertoken');
        System.assertEquals(null, testUser.Name);
    }

    @isTest static void testRegisterNewUserInvalidRecord() {
        User__c testUser = new User__c(Name = 'Test User', Email__c = 'email@example.com');

        try {
            OnlineStoreController.registerNewUser(testUser, 'test_pass');
            System.assertEquals(true, false); // inaccessible line
        } catch (DmlException e) {}

        System.assertEquals(null, testUser.Id);
    }

    @isTest static void testRegisterNewUser() {
        User__c testUser = new User__c(
            Name = 'Test User x', 
            Email__c = 'test_user_x@example.com',
            Login__c = 'test_user_x'
        );

        OnlineStoreController.registerNewUser(testUser, 'test_pass_x');

        System.assertNotEquals(null, testUser.Id);
        System.assertEquals('Test User x', testUser.Name);
        System.assertNotEquals(null, testUser.Token__c);
    }

    @isTest static void testUpdateUser() {
        User__c user = [
            SELECT Id, Email__c, Login__c 
            FROM User__c 
            WHERE Login__c = 'test_user_3'
        ];

        user.Email__c = 'newemail@example.com';
        OnlineStoreController.updateUser(user);

        user = [
            SELECT Id, Email__c, Login__c 
            FROM User__c 
            WHERE Login__c = 'test_user_3'
        ];

        System.assertNotEquals('test_user_3@example.com', user.Email__c);
        System.assertEquals('newemail@example.com', user.Email__c);
    }

    @isTest static void testUpdateUserPassword() {
        String login = 'test_user_4';

        User__c user = [
            SELECT Id, Login__c, PassHash__c 
            FROM User__c 
            WHERE Login__c = :login
        ];

        String newpass = 'newpass';
        OnlineStoreController.updateUserPassword(user.Id, newpass);
        user = OnlineStoreController.authUser(login, newpass);

        System.assertNotEquals(null, user.Id);
    }
}