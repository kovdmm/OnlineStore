({
    clickLogout: function(component, event, helper) {
        console.log('[onlineStoreHeader.clickLogout]');
        helper.fireuserUpdateEvent(false, {});
        helper.fireShowMessageEvent('Success!', 'You successfully logged out.', 'info');
    },

    updateLocation: function(component, event, helper) {
        var location = event.getSource().get('v.name');

        console.log('[onlineStoreHeader.updateLocation] location =', location);

        helper.fireLocationUpdateEvent(event.getSource().get('v.name'));
    },

    // In case if location changed somewhere else except header component
    handleLocationUpdate: function(component, event, helper) {
        var location = event.getParam('location');

        console.log('[onlineStoreHeader.handleLocationUpdate] location =', location);

        // Make current page navigation button disabled
        var navigationButtons = component.find('navigation');
        navigationButtons.forEach(function (button) {
            var nameParam = button.get('v.name');
            if (nameParam == location) {
                button.set('v.disabled', true);
            } else {
                button.set('v.disabled', false);
            }
        });
    }
});