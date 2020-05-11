({
    clickUpdateLocation: function(component, event, helper) {
        var location = event.getSource().get('v.name');
        console.log('[onlineStoreCartSidebar.clickUpdateLocation] location =', location);
        helper.redirect(location);
    }
});
