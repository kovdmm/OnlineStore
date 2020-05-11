({
    redirect: function(location) {
        var event = $A.get('e.c:locationUpdateEvent');
        event.setParam('location', location);
        event.fire();
    }
});
