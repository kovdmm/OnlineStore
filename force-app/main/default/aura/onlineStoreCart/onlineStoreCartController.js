({
    init: function(component, event, helper) {
        var userId = component.get('v.user').Id;
        var location = component.get('v.location');

        console.log('[onlineStoreCart.init] userId =', userId, 'location =', location);

        if (location == 'cart') helper.retrieveCart(component, userId);
        if (location == 'paid') helper.retrievePaidItems(component, userId);
    },

    clickRemoveFromCart: function(component, event, helper) {
        var userId = component.get('v.user').Id;
        var productId = event.getSource().get('v.name');

        console.log('[onlineStoreCart.clickRemoveFromCart] userId =', userId, 'productId =', productId);

        helper.removeFromCart(component, userId, productId);
    },

    clickPayOrder: function(component, event, helper) {
        var userId = component.get('v.user').Id;

        helper.payOrder(component, userId);
    }
});