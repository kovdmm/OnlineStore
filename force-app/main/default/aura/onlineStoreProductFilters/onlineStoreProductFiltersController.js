({
    init: function(component, event, helper) {
        var chosenCategories = component.get('v.chosenCategories') || [];
        helper.retrieveCategories(component, chosenCategories);
    },
    clickShowResults: function(component, event, helper) {
        var minPrice = component.get('v.minPrice');
        var maxPrice = component.get('v.maxPrice');
        var chosenCategories = [];

        var selectors = component.find('categorySelector');
        selectors.forEach(function (cmp) {
            var value = cmp.get('v.value');
            if (value) chosenCategories.push(value);
        });

        var filtersUpdateEvent = component.getEvent('filtersUpdateEvent');
        filtersUpdateEvent.setParams({
            'minPrice': minPrice,
            'maxPrice': maxPrice,
            'chosenCategories': chosenCategories
        });
        filtersUpdateEvent.fire();
    }
});