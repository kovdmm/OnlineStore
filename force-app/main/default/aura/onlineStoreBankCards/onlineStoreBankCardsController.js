({
    init: function(component, event, helper) {
        var userId = component.get('v.user').Id;

        helper.retrieveCards(component, userId);
    },

    clickSaveNewCard: function(component, event, helper) {
        var user = component.get('v.user');
        var newCard = component.get('v.newCard');
        newCard.OwnerId__c = user.Id;

        console.log('[onlineStoreBankCards.clickSaveNewCard] newCard =', JSON.stringify(newCard));
        
        helper.saveNewCard(component, newCard);
    },

    clickDeleteCard: function(component, event, helper) {
        var user = component.get('v.user');
        var cardId = event.getSource().get('v.name');

        helper.deleteCard(component, user, cardId);
    },

    clickSetDefaultCard: function(component, event, helper) {
        var cardId = event.getSource().get('v.name');

        helper.fireUserDefaultCardUpdateEvent(component, cardId);
    }
})