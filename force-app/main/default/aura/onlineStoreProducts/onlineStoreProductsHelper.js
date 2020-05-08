({
    retrieveProducts: function(component, page, productsOnPage, filters) {
        var actionName = filters ? 'c.getProductsUsingFilters' : 'c.getProducts';
        var action = component.get(actionName);
        action.setParams({
            'page': page,
            'productsOnPage': productsOnPage
        });
        if (filters) action.setParam('filters', JSON.stringify(filters));
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = JSON.parse(response.getReturnValue());
                var products = result.products;
                var totalPages = result.totalPages;

                console.log('[REMOTE CALL] [OnlineStoreProductsController.getProducts] state =', state, 'totalPages =', totalPages, 'products =', JSON.stringify(products));
                
                component.set('v.products', products);
                component.set('v.totalPages', totalPages);
                component.set('v.page', page);
            } else {
                console.log('[REMOTE CALL] [OnlineStoreProductsController.getProducts] state =', state);
            }
        });
    },

    fireRemoteCall: function(action, callback) {
        action.setCallback(this, callback);
        $A.enqueueAction(action);
    },

    setPage: function(component, page) {
        var productsOnPage = component.get('v.productsOnPage');
        var filters = component.get('v.filters');
        console.log(typeof filters);
        this.retrieveProducts(component, page, productsOnPage, filters);
    },

    addToCart: function(component, userId, productId) {
        var action = component.get('c.addToCart');
        action.setParams({
            'productId': productId,
            'userId': userId,
            'quantity': 1
        });
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var cartItemsCount = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreProductsController.getProducts] cartItemsCount =', cartItemsCount);
                
                this.fireCartItemsCountUpdateEvent(cartItemsCount);
            } else {
                console.log('[REMOTE CALL] [OnlineStoreProductsController.getProducts] state =', state);
            }
        });
    },

    redirectToLogin: function() {
        var locationUpdateEvent = $A.get('e.c:locationUpdateEvent'); // component.getEvent('locationUpdateEvent');
        locationUpdateEvent.setParams({ 'location': 'login' });
        locationUpdateEvent.fire();
    },

    fireCartItemsCountUpdateEvent: function(cartItemsCount) {
        var event = $A.get('e.c:cartItemsCountUpdateEvent');
        event.setParams({ 'cartItemsCount': cartItemsCount });
        event.fire();
    }
});
