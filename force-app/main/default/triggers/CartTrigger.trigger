trigger CartTrigger on Cart__c (before update) {
	OnlineStoreCartController.updateStatusTrigger(Trigger.New, Trigger.oldMap);
}