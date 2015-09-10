trigger CustomRepaymentReversalTrigger on loan__Repayment_Transaction_Adjustment__c (after insert,after update) {
    if(!loan.CustomSettingsUtil.getOrgParameters().loan__Disable_Triggers__c){
        
        CustomRepaymentReversalTriggerHandler handler = new CustomRepaymentReversalTriggerHandler(trigger.new,
                                                                                    trigger.oldMap);
        
        if(trigger.isAfter && trigger.isUpdate) {
            handler.onAfterUpdate();
        }
    }
}