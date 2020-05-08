({
    redirect: function(location) {
        console.log('[onlineStore.helper.redirect] location =', location);

        var locationUpdateEvent = $A.get('e.c:locationUpdateEvent');
        locationUpdateEvent.setParams({ 'location': location });
        locationUpdateEvent.fire();
    },


    // All access rules here: 
    setLocationAndRedirectIfNeeded: function(component, userAuthorized, location) {
        if (userAuthorized && this.locationInArray(location, ['login', 'register'])) {
            this.redirect('home');
        } else if (!userAuthorized && this.locationInArray(location, ['cart', 'order_reg', 'order_pay', 'user'])) {
            this.redirect('login');
        } else {
            component.set('v.location', location);
        }
    },

    locationInArray: function(location, array) {
        // returns true if array contains location
        return array.indexOf(location) >= 0;
    },

    showMessage: function(title, message, type) {
        var text = '[' + type + '] ' + title + '\n' + message;
        alert(text);
        console.log(text);
    },

    updateUserAuth: function(component, userToken) {
        var action = component.get('c.getUserByToken');

        action.setParams({
            'token': userToken
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var user = {};
            var isAuthorized = false;

            if (state === 'SUCCESS') {
                user = response.getReturnValue();
                if (user.Token__c) isAuthorized = true;

                this.updateCartItemsCount(component, user.Id);
            }
            
            console.log('[REMOTE CALL] [OnlineStoreController.getUserByToken] state =', state, 'user =', JSON.stringify(user));
            
            var userUpdateEvent = $A.get('e.c:userUpdateEvent');
            userUpdateEvent.setParams({
                'user': user,
                'isAuthorized': isAuthorized
            });
            userUpdateEvent.fire();
        });

        // Send action to be executed
        $A.enqueueAction(action);
    },
    
    updateLocation: function(component, location) {
        if (!location) location = localStorage.getItem('location') || 'home';
        var userAuthorized = !!component.get('v.user').Token__c;

        console.log('[onlineStore.helper.updateLocation] location =', location, 'userAuthorized =', userAuthorized);

        this.setLocationAndRedirectIfNeeded(component, userAuthorized, location);

        localStorage.setItem('location', location);
    },

    updateCartItemsCount: function(component, userId) {
        var action = component.get('c.getCartItemsCount');
        action.setParams({
            'userId': userId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var cartItemsCount = response.getReturnValue();
                
                component.set('v.cartItemsCount', cartItemsCount);
            }
        })
        $A.enqueueAction(action);
    }
});