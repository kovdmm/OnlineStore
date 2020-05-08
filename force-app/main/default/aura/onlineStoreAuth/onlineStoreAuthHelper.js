({
    authUser: function(component, login, password) {
        if (login == '' || password == '') {
            this.fireShowMessageEvent('Fill All Fields!', 'Fields must not be empty.', 'error');
            return;
        }

        this.fireRemoteAuthAction(component, 'c.authUser', {
            'login': login,
            'password': password
        });
    },

    registerNewUser: function(component, user, password) {
        this.fireRemoteAuthAction(component, 'c.registerNewUser', {
            'user': user,
            'password': password
        });
    },

    updateUser: function(component, user) {
        var action = component.get('c.updateUser');

        action.setParams({
            'user': user
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                user = response.getReturnValue();
                this.fireShowMessageEvent('Saved!', 'Your data have been successfully saved.', 'info');
                this.fireuserUpdateEvent(true, user);
            }

            if (state === 'ERROR') {
                this.fireShowMessageEvent('Invalid input!', 'Try again.', 'error');
            }
        });

        $A.enqueueAction(action);
    },

    fireRemoteAuthAction: function(component, controllerMethod, params) {
        var action = component.get(controllerMethod);

        action.setParams(params);

        action.setCallback(this, function (response) {
            var state = response.getState();

            var user = {};
            var userAuthorized = false;
            if (state === "SUCCESS") {
                user = response.getReturnValue();
                if (user.Token__c) userAuthorized = true;
            }

            if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    this.fireShowMessageEvent('Failed!', errors[0].message, 'error');
                    return;
                }

                this.fireShowMessageEvent('Failed!', errors[0].message, 'error');
            }

            console.log('[REMOTE CALL] [OnlineStoreController] [' + controllerMethod + '] state =', state, 'userAuthorized =', userAuthorized);

            this.fireuserUpdateEvent(userAuthorized, user);

            if (userAuthorized) this.cleanFields(component);
        });

        $A.enqueueAction(action);
    },

    fireShowMessageEvent: function(title, message, type) {
        var showMessage = $A.get('e.c:showMessageEvent');
        showMessage.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        showMessage.fire();
    },

    fireuserUpdateEvent: function(isAuthorized, user) {
        var userUpdateEvent = $A.get('e.c:userUpdateEvent');
        userUpdateEvent.setParams({ 
            'isAuthorized': isAuthorized,
            'user': user 
        });
        userUpdateEvent.fire();
    },

    cleanFields: function(component) {
        component.set('v.login', '');
        component.set('v.password', '');
    }
});