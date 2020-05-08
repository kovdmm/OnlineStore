({
    login: function(component, event, helper) {
        var login = component.get('v.login');
        var password = component.get('v.password');

        helper.authUser(component, login, password);
    },

    register: function(component, event, helper) {
        var user = component.get('v.user');
        var password = component.get('v.password');

        console.log('[onlineStoreAuth.register] user =', JSON.stringify(user), 'password =', password);

        helper.registerNewUser(component, user, password);
    },

    saveUserData: function(component, event, helper) {
        var user = component.get('v.user');

        console.log('[onlineStoreAuth.saveUserData] user =', JSON.stringify(user));

        helper.updateUser(component, user);
    },

    handleUserDefaultCardUpdate: function(component, event, helper) {
        var user = component.get('v.user');
        var cardId = event.getParam('cardId');
        user.DefaultCardId__c = cardId;
        component.set('v.user', user);

        console.log('[onlineStoreAuth.handleUserDefaultCardUpdate] user =', JSON.stringify(user), 'cardId =', cardId);
    }
});