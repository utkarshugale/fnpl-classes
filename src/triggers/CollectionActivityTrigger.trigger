trigger CollectionActivityTrigger on collect__Collection_Activity__c (before insert) {

    List<collect__Collection_Activity__c> collectionActivitiesList = Trigger.new;

    for(collect__Collection_Activity__c colAct : collectionActivitiesList) {

        colAct.Loan_Contract__c = colAct.collect__Loan_Account_Id__c;
    }
}