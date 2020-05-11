({
    clickRemoveFromCart: function(component, event, helper) {
        var userId = component.get('v.userId');
        var productId = component.get('v.item').ProductId__c;

        console.log('[onlineStoreCartItem.clickRemoveFromCart] userId =', userId, 'productId =', productId);

        helper.removeFromCart(component, userId, productId);
    },

    clickIncQuantity: function(component, event, helper) {
        var userId = component.get('v.userId');
        var item = component.get('v.item');
        var productId = item.ProductId__c;
        var quantity = item.Quantity__c;

        helper.updateQuantity(component, userId, productId, quantity + 1);
    },
    
    clickDecQuantity: function(component, event, helper) {
        var userId = component.get('v.userId');
        var item = component.get('v.item');
        var productId = item.ProductId__c;
        var quantity = item.Quantity__c;

        helper.updateQuantity(component, userId, productId, quantity - 1);
    }
});
