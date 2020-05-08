({
    retrieveCards: function(component, userId) {
        var action = component.get('c.getCards');
        action.setParams({ 'userId': userId });
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var cards = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreBankingController.getCards] state =', state, 'cards =', JSON.stringify(cards));
                
                component.set('v.cards', cards);
            } else {
                console.log('[REMOTE CALL] [OnlineStoreBankingController.getCards] state =', state);
            }
        });
    },

    saveNewCard: function(component, newCard) {
        var action = component.get('c.saveNewCard');
        action.setParams({ 'newCard': newCard });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var card = response.getReturnValue();
                var cards = component.get('v.cards');
                cards.unshift(card);
                component.set('v.cards', cards);

                console.log('[REMOTE CALL] [OnlineStoreBankingController.saveNewCard] state =', state, 'card =', JSON.stringify(card));
            } else {
                console.log('[REMOTE CALL] [OnlineStoreBankingController.saveNewCard] state =', state);
                console.log(response.getError()[0] || 'Unknown Error');
            }
        });
        $A.enqueueAction(action);
    },

    deleteCard: function(component, user, cardId) {
        var action = component.get('c.deleteCard');
        action.setParams({ 'cardId': cardId });
        this.fireRemoteCall(action, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var deleted = response.getReturnValue();

                console.log('[REMOTE CALL] [OnlineStoreBankingController.deleteCard] state =', state, 'deleted =', deleted);
                
                this.retrieveCards(component, user.Id);
                if (user.DefaultCardId__c == cardId) {
                    // update if default deleted
                    this.fireUserDefaultCardUpdateEvent(component, null);
                }
            } else {
                console.log('[REMOTE CALL] [OnlineStoreBankingController.deleteCard] state =', state);
                console.log(response.getError()[0] || 'Unknown Error');
            }
        });
    },

    fireUserDefaultCardUpdateEvent: function(component, cardId) {
        var event = component.getEvent('userDefaultCardUpdateEvent');
        event.setParams({ 'cardId': cardId });
        event.fire();
    },

    fireUserUpdateEvent: function(user) {
        var event = $A.get('e.c:userUpdateEvent');
        event.setParams({
            'user': user,
            'isAuthorized': true
        });
        event.fire();
    },

    fireRemoteCall: function(action, callback) {
        action.setCallback(this, callback);
        $A.enqueueAction(action);
    }
});