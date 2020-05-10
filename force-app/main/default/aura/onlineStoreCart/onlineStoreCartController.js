({
    init: function(component, event, helper) {
        var userId = component.get('v.user').Id;
        helper.retrieveCart(component, userId);
    },
    clickRemoveFromCart: function(component, event, helper) {
        var userId = component.get('v.user').Id;
        var productId = event.getSource().get('v.name');

        console.log('[onlineStoreCart.clickRemoveFromCart] userId =', userId, 'productId =', productId);

        helper.removeFromCart(component, userId, productId);
    },

    clickPlaceOrder: function(component, event, helper) {
        var userId = component.get('v.user').Id;

        helper.createOrder(component, userId);
    }
});