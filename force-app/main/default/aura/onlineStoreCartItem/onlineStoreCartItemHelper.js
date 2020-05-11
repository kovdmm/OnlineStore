({
    removeFromCart: function(component, userId, productId) {
        var action = component.get('c.removeFromCart');
        action.setParams({
            'userId': userId,
            'productId': productId
        });
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var deleted = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreCartController.removeFromCart] deleted =', deleted);

                this.fireCartUpdateEvent(component);
            } else {
                console.log('[REMOTE CALL] [OnlineStoreCartController.removeFromCart] state =', state);
            }
        });
    },

    updateQuantity: function(component, userId, productId, quantity) {
        var action = component.get('c.updateQuantity');
        action.setParams({
            'userId': userId,
            'productId': productId,
            'quantity': quantity
        });
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var updated = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreCartController.updateQuantity] updated =', updated);

                this.fireCartUpdateEvent(component);
            } else {
                console.log('[REMOTE CALL] [OnlineStoreCartController.updateQuantity] state =', state);
            }
        });
    },

    fireRemoteCall: function(action, callback) {
        action.setCallback(this, callback);
        $A.enqueueAction(action);
    },

    fireCartUpdateEvent: function(component) {
        var event = component.getEvent('cartUpdateEvent');
        event.fire();
    }
});
