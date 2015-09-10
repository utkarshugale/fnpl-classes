public with sharing class BillsTriggerCustomhandler {
    
    private List<loan__Loan_account_Due_Details__c> newList;
    private Map<Id,loan__Loan_account_Due_Details__c> oldMap;
    
    private Id rtId;
    private Map<Id,loan__Loan_Account__c> loanMap;
    
    private Set<Id> loanIds;
    
    public BillsTriggerCustomhandler(List<loan__Loan_account_Due_Details__c> newList, Map<Id,loan__Loan_account_Due_Details__c> oldMap) {
    
        this.newList = newList;
        this.oldMap = oldMap;
        loanIds = new Set<ID>();
        
        for(loan__Loan_account_Due_Details__c d : newList){
            loanIds.add(d.loan__Loan_Account__c);
        }
        
        loanMap = new Map<Id,loan__Loan_Account__c>([Select Id,Name,
                                                            RecordTypeId,
                                                            loan__Credit_Limit__c,
                                                            loan__Minimum_Draw_Amount__c,
                                                            loan__Minimum_Due_Amount_On_Billing__c
                                                     From loan__Loan_Account__c
                                                     Where Id in: loanIds]);
        
        rtId = [Select Id,Name 
                From RecordType Where DeveloperName = 'Line_Of_Credit_Record_Type' 
                AND sObjectType = 'loan__Loan_Account__c'].Id;
    
    }
    
    public void onAfterInsert(){ 
        loan__Loan_Account__c loan;
        
        for(loan__Loan_account_Due_Details__c lDetails : newList) {
            loan = loanMap.get(lDetails.loan__Loan_Account__c);
            if(loan.RecordTypeId == rtId
                && loan.loan__Minimum_Due_Amount_On_Billing__c != null
                && loan.loan__Minimum_Due_Amount_On_Billing__c > 0
                && loan.loan__Minimum_Due_Amount_On_Billing__c < 25){
                
                lDetails.loan__Due_Amt__c = loan.loan__Minimum_Due_Amount_On_Billing__c;
            }
        }
        
    }
}