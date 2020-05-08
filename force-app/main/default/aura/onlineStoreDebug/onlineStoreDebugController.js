({
    updateLocation: function(component, event, helper) {
        // retrieve data from source component
        var sourceComponent = event.getSource();
        var location = sourceComponent.get('v.name');

        console.log('[onlineStoreDebug.updateLocation] location =', location);

        // firing event with parameter
        var locationUpdateEvent = $A.get('e.c:locationUpdateEvent');
        locationUpdateEvent.setParams({ 'location': location });
        locationUpdateEvent.fire();
    },

    authUser: function(component, event, helper) {
        var sourceComponent = event.getSource();
        var actionType = sourceComponent.get('v.name');

        console.log('[onlineStoreDebug.updateAuth] actionType =', actionType);

        var userUpdateEvent = $A.get('e.c:userUpdateEvent');
        if (actionType == 'login') {
            userUpdateEvent.setParams({ 
                'isAuthorized': true,
                'user': {
                    'Id': '0Af5I000001vg2dSAA',
                    'Token__c': 'uOyx/9n3olN5vwBDVmwdpEK0atwhgB458a0oIAMtSak=',
                    'Name': 'Test User',
                    'Login__c': 'Test',
                    'Email__c': 'test@example.com',

                    'Street__c': '121 Spear St.',
                    'City__c': 'San Francisco',
                    'Country__c': 'United States',
                    'Province__c': 'CA',
                    'PostalCode__c': '94105'
                }
            });
        }
        if (actionType == 'logout') {
            userUpdateEvent.setParams({ 
                'isAuthorized': false,
                'user': {}
            });
        }
        userUpdateEvent.fire();
    }
});