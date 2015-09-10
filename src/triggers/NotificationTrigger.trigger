trigger NotificationTrigger on cnotify__Notification__c (before insert) {
    NotificationTriggerHandler handler = new NotificationTriggerHandler(trigger.new,trigger.oldMap);
    
    if(trigger.isBefore){
        if(Trigger.isInsert){
            handler.beforeInsertHandler();
        }
    }
}