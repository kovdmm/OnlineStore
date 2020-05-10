({
    init: function(component, event, helper) {
        var userId = component.get('v.user').Id;
        helper.retrieveCart(component, userId);
    }
});