({
    init: function(component, event, helper) {
        helper.retrieveCart(component, component.get('v.user').Id);
    }
});