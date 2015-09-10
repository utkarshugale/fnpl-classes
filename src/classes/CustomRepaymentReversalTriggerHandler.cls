public class CustomRepaymentReversalTriggerHandler {
    private List<loan__Repayment_Transaction_Adjustment__c> txnList;
    private List<loan__Repayment_Transaction_Adjustment__c> refundProcess;
    private Map<Id,loan__Repayment_Transaction_Adjustment__c> oldMap;
    
    private loan__Transaction_Approval_Config__c approvalConfig;
    
    private Set<Id> txnIds = new SeT<Id>();
    private Set<ID> borrowerIDs = new Set<Id>();
    private Map<Id,loan__Repayment_Transaction_Adjustment__c> requeriedMap;
    private Map<Id,loan__Loan_Payment_Transaction__c> paymentMap;
    private List<loan__Loan_Payment_Transaction__c> paymentList;
    private Map<Id,loan__Bank_Account__c> borrowerCardDetailsMap;
    
    private List<Payment_Retry__c> recsToCreate;
    private Datacash_Config__c config;
    
    public CustomRepaymentReversalTriggerHandler(List<loan__Repayment_Transaction_Adjustment__c> txnList,
                                          Map<Id,loan__Repayment_Transaction_Adjustment__c> oldMap) {
    
        this.txnList = txnList;
        this.oldMap = oldMap;
        
        recsToCreate = new List<Payment_Retry__c>();
        refundProcess = new List<loan__Repayment_Transaction_Adjustment__c>();
        paymentMap = new Map<Id,loan__Loan_Payment_Transaction__c>();
        borrowerCardDetailsMap = new Map<Id,loan__Bank_Account__c>();
        paymentList = new List<loan__Loan_Payment_Transaction__c>();
        
        approvalConfig = loan__Transaction_Approval_Config__c.getOrgDefaults();
        
        //get custom setting details to Send payment to Datacash
        config = Datacash_Config__c.getOrgDefaults();   
        
        //Get Txn IDs for requery.
        for(loan__Repayment_Transaction_Adjustment__c txn : txnList) {
            txnIDs.add(txn.Id);
            
        }
        
        requeriedMap = new Map<Id,loan__Repayment_Transaction_Adjustment__c>([Select Id,Name,
                                                                                     loan__Loan_Payment_Transaction__c,
                                                                                     loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__c,
                                                                                     loan__Loan_Payment_Transaction__r.loan__Transaction_Amount__c,
                                                                                     loan__Loan_Payment_Transaction__r.loan__Loan_Account__c,
                                                                                     loan__Loan_Payment_Transaction__r.Datacash_Reference__c,
                                                                                     loan__Loan_Payment_Transaction__r.Merchant_Reference__c,
                                                                                     loan__Loan_Payment_Transaction__r.Payment_Type__c
                                                                              From loan__Repayment_Transaction_Adjustment__c
                                                                              Where Id in :txnIDs]);
                                                                              
        /*Prepare map for Reversals vs its lpt.
        for(loan__Repayment_Transaction_Adjustment__c reqRec : requeriedMap.values()) {
            borrowerIds.add(reqRec.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__c);
            paymentMap.put(reqRec.Id,reqRec.loan__Loan_Payment_Transaction__r);
        }
        
        //Query borroers & its bank details.
        List<Contact> borrowers = [Select Id,Name,
                                          (Select Id,Name,
                                                  Bank_Card_Details__c,
                                                  Expiry_Month__c,
                                                  Expiry_Year__c,
                                                  CVV__c,
                                                  loan__Active__c
                                           from loan__Bank_Accounts__r
                                           Where loan__Active__c = true)
                                   From Contact
                                   Where Id in :borrowerIds];
        
        for(Contact c : borrowers) {
            if(c.loan__Bank_Accounts__r != null && !c.loan__Bank_Accounts__r.isEmpty()) {
                borrowerCardDetailsMap.put(c.Id,c.loan__Bank_Accounts__r[0]);
            }
        }*/
    }
    
    public void onAfterUpdate() {
        loan__Repayment_Transaction_Adjustment__c beforeUpdate;
        
        BorrowerImpl impl = new BorrowerImpl();
         
        for(loan__Repayment_Transaction_Adjustment__c adjTxn : txnList) { 
            beforeUpdate = oldMap.get(adjTxn.Id);
            
            if(beforeUpdate.loan__cleared__c == false 
                && adjTxn.loan__cleared__c == true 
                && adjTxn.Attempt_Retry__c
                && requeriedMap.get(adjTxn.Id).loan__Loan_Payment_Transaction__r.Payment_Type__c != 'Retry') {
               
               System.debug(LoggingLEvel.ERROR,' Creating txn ');
                
               recsToCreate.add(getPaymentRetryOrder(adjTxn));       
            
            }
        }
        
        //Create Retry Transaction Order for Loans.
        SavePoint sp = Database.setSavePoint();
        try {
            insert recsToCreate;
            System.debug(LoggingLevel.ERROR,' Updated Successfully');
        }catch(Exception e){
            Database.rollback(sp);
            loan__Batch_Process_Log__c errorLog = new loan__Batch_Process_Log__c();
            errorLog.loan__Message__c = 'Error : LoanPaymentReversalTrigger: '+e.getMessage()+' from line '+e.getLineNumber();
            errorLog.loan__Date__c = Date.newInstance(System.now().year(),System.now().month(),System.now().day());
            
            insert errorLog;
        }
    }
    
    /*
    
    @future
    public static void processDatacashRefunds() {
        loan__Bank_Account__c activeCard;
        Datacash_Config__c config = Datacash_Config__c.getOrgDefaults();  
        
        for(loan__Repayment_Transaction_Adjustment__c adjTxn : tList) {
            if(adjTxn.Process_Refund__c){ 
                System.debug(LoggingLevel.ERROR,' Processing Refund ');
                activeCard = borrowerCardDetailsMap.get(requeriedMap.get(adjTxn.Id)
                                                                    .loan__Loan_Payment_Transaction__r
                                                                    .loan__Loan_Account__r
                                                                    .loan__Contact__c);
                
                if(activeCard != null) {
                   //Send to Datacash.
                    PaymentTransactionResponse payResponse = impl.sendPaymentToDataCashRefund(config.Server_Url__c,
                                                                                           config.Username__c,
                                                                                           config.password__c,
                                                                                           activeCard,
                                                                                           paymentMap.get(adjTxn.Id));
                    
                    //If Response is success, 
                    if(payResponse.successMessage.equals('SUCCESS')) {
                        System.debug(LoggingLevel.ERROR,' Refund Successful.');
                        paymentList.add(payResponse.lpt);
                    }else {
                        //Datacash refund unsuccessful. [ask TF].
                    }                                                                
                }//end second if.
                
            }//end first if
            
        }//end for loop.
        
        if(!paymentList.isEmpty()) {
            update paymentList;
        }    
    }*/
    
    private Payment_Retry__c getPaymentRetryOrder(loan__Repayment_Transaction_Adjustment__c adj) {
        
        Decimal interval = (approvalConfig.Payment_Retry_Interval__c == null) ? 7 : approvalConfig.Payment_Retry_Interval__c;
    
        Payment_Retry__c retVal = new Payment_Retry__c();
        retVal.Transaction_Date__c = adj.loan__Adjustment_Txn_Date__c.addDays((Integer)interval);
        retVal.Debit_amount__c = (adj.loan__Adjusted_Amount__c == 0 || adj.loan__Adjusted_Amount__c == null) 
                                ? requeriedMap.get(adj.Id).loan__Loan_Payment_Transaction__r.loan__Transaction_Amount__c
                                : adj.loan__Adjusted_Amount__c;
        retVal.CL_Contract__c = requeriedMap.get(adj.Id).loan__Loan_Payment_Transaction__r.loan__Loan_Account__c;
        
        return retVal;
    }
    
}