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
                component.set('v.cartTotalPrice', this.calculateBill(cart));
            } else {
                console.log('[REMOTE CALL] [OnlineStoreProductsController.getCart] state =', state);
            }
        });
    },

    retrievePaidItems: function(component, userId) {
        var action = component.get('c.getPaidItems');
        action.setParams({
            'userId': userId,
            'productId': productId
        });
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var deleted = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreProductsController.removeFromCart] deleted =', deleted);

                var cart = component.get('v.cart').filter(function(cartItem) {
                    return cartItem.ProductId__c != productId;
                });

                component.set('v.cart', cart);
                component.set('v.totalPrice', this.calculateBill(cart));
            } else {
                console.log('[REMOTE CALL] [OnlineStoreProductsController.removeFromCart] state =', state);
            }
        });
    },

    createOrder: function(component, userId) {
        var action = component.get('c.createOrder');
        action.setParams({
            'userId': userId
        });
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var order = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreProductsController.createOrder] order =', JSON.stringify(order));

                // Go to updaid orders page to perform payment for order
            } else {
                console.log('[REMOTE CALL] [OnlineStoreProductsController.createOrder] state =', state);
            }
        });
    },

    calculateBill: function(cart) {
        var bill = 0;
        for (var i in cart) {
            var cartItem = cart[i];
            bill += cartItem.Quantity__c * cartItem.ProductId__r.Price__c;
        }
        return bill.toFixed(2);
    },

    fireRemoteCall: function(action, callback) {
        action.setCallback(this, callback);
        $A.enqueueAction(action);
    }
});