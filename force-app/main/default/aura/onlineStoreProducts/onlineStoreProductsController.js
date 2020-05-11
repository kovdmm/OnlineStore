({
    init: function(component, event, helper) {
        var page = component.get('v.page');
        var productsOnPage = component.get('v.productsOnPage');

        helper.retrieveProducts(component, page, productsOnPage);
    },

    handleFiltersUpdateEvent: function(component, event, helper) {
        var filters = {
            minPrice: event.getParam('minPrice') || 0,
            maxPrice: event.getParam('maxPrice') || 100000,
            chosenCategories: event.getParam('chosenCategories')
        };
        var productsOnPage = component.get('v.productsOnPage');

        // fill v.filters attribute for correct pagination
        component.set('v.filters', filters);

        // reset page number
        var page = 1; 

        component.set('v.page', page);
        helper.retrieveProducts(component, page, productsOnPage, filters);
    },

    clickNextPage: function(component, event, helper) {
        var page = component.get('v.page');
        helper.setPage(component, page + 1);
    },

    clickPrevPage: function(component, event, helper) {
        var page = component.get('v.page');
        helper.setPage(component, page - 1);
    },

    clickAddToCart: function(component, event, helper) {
        var user = component.get('v.user');
        if (!user.Token__c) return helper.redirectToLogin();

        var productId = event.getSource().get('v.name');

        helper.addToCart(component, user.Id, productId);
    },

    productsOnPageChanged: function(component, event, helper) {
        var productsOnPage = event.getSource().get('v.value');
        var page = 1;

        component.set('v.page', page);
        component.set('v.productsOnPage', productsOnPage);
        helper.retrieveProducts(component, page, productsOnPage);
    }
});
