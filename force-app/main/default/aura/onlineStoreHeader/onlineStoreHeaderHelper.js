({
    fireuserUpdateEvent: function(isAuthorized, user) {
        var userUpdateEvent = $A.get('e.c:userUpdateEvent');
        userUpdateEvent.setParams({ 
            'isAuthorized': isAuthorized,
            'user': user 
        });
        userUpdateEvent.fire();
    },

    fireShowMessageEvent: function(title, message, type) {
        // e.force:showToast doesn't work in Lightning App (Salesforce1 only)
        var showMessage = $A.get('e.c:showMessageEvent');
        showMessage.setParams({
            'title': title,
            'message': message,
            'type': type
        });
        showMessage.fire();
    },

    fireLocationUpdateEvent: function(location) {
        // NOTE:
        // [i] According to: https://developer.salesforce.com/blogs/developer-relations/2015/03/lightning-component-framework-custom-events.html
        // [i] ... and: https://salesforce.stackexchange.com/questions/137052/component-events-vs-application-events-component-getevent-vs-a-get
        var locationUpdateEvent = $A.get('e.c:locationUpdateEvent'); // component.getEvent('locationUpdateEvent');
        locationUpdateEvent.setParams({ 'location': location });
        locationUpdateEvent.fire();
    }
});