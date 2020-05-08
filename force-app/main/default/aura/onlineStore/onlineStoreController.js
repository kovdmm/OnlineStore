({
    init: function(component, event, helper) {
        var userToken = localStorage.getItem('userToken') || '';
        var location = localStorage.getItem('location') || 'home';

        console.log('[onlineStore.init] userToken =', userToken || null, 'location =', location);

        if (userToken) helper.updateUserAuth(component, userToken);
        helper.redirect(location);

        window.document.title = 'OnlineStore';
    },

    handleLocationUpdate: function(component, event, helper) {
        var newLocation = event.getParam('location');

        console.log('[onlineStore.handleLocationUpdate] newLocation =', newLocation);

        helper.updateLocation(component, newLocation);
    },

    handleUserAuth: function(component, event, helper) {
        var userAuthorized = event.getParam('isAuthorized');
        var user = event.getParam('user');

        console.log('[onlineStore.handleUserAuth] userAuthorized =', userAuthorized, 'user =', JSON.stringify(user));

        localStorage.setItem('userToken', user.Token__c || '');
        component.set('v.user', user);

        helper.updateLocation(component);
    },

    handleShowMessage: function(component, event, helper) {
        var title = event.getParam('title') || '';
        var message = event.getParam('message') || '';
        var type = event.getParam('type') || 'info';

        helper.showMessage(title, message, type);
    },

    handleCartItemsCountUpdate: function(component, event, helper) {
        var cartItemsCount = event.getParam('cartItemsCount');

        component.set('v.cartItemsCount', cartItemsCount);
    }
});