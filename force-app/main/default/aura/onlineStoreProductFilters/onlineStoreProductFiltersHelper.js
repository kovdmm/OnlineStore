({
    retrieveCategories: function(component, chosenCategories) {
        var action = component.get('c.getCategories');
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var categories = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreProductsController.getCategories] categories =', JSON.stringify(categories));
                
                component.set('v.categories', categories);
            } else {
                console.log('[REMOTE CALL] [OnlineStoreProductsController.getCategories] state =', state);
            }
        });
    },

    fireRemoteCall: function(action, callback) {
        action.setCallback(this, callback);
        $A.enqueueAction(action);
    }
});