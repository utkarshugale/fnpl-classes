trigger BillsTriggerCustom on loan__Loan_account_Due_Details__c (before insert) {
    
    BillsTriggerCustomhandler handler = new BillsTriggerCustomHandler(trigger.new,trigger.oldMap);
    handler.onAfterinsert();
    
    
}