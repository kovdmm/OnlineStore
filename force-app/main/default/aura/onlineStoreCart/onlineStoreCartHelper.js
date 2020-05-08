({
    retrieveCart: function(component, userId) {
        var action = component.get('c.getCart');
        action.setParams({
            'userId': userId
        });
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var cart = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreProductsController.getCart] cart =', JSON.stringify(cart));

                component.set('v.cart', cart);
            } else {
                console.log('[REMOTE CALL] [OnlineStoreProductsController.getCart] state =', state);
            }
        });
    },

    fireRemoteCall: function(action, callback) {
        action.setCallback(this, callback);
        $A.enqueueAction(action);
    }
});