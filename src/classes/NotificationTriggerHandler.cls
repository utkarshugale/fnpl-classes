/* 
* Handler class for NotificationTrigger.
* 
* Functions:
* Before Insert : 1. Assigns Target Object Record to Lookup.
*                 
*/
public with sharing class NotificationTriggerHandler {
    private List<cnotify__Notification__c> newList;
    private Map<Id,cnotify__Notification__c> oldMap;
    
    public NotificationTriggerHandler(List<cnotify__Notification__c> newList, Map<Id,cnotify__Notification__c> oldMap){
        this.newList = newList;
        this.oldMap = oldMap;
    }
    
    public void beforeInsertHandler(){
        
        /*
        * assignes Loan Account record to notification.
        */
        for(cnotify__Notification__c notification : newList){
            notification.CL_Contract__c = notification.cnotify__Target_Object_Id__c;
        }
    }
}