public class LoanPaymentTransactionRetryJob implements Database.Batchable<sObject>, Schedulable {
    private String query;
    private List<loan__Loan_Payment_Transaction__c> loanPayments;
    private loan__Payment_Mode__c pMode;
    private List<loan__Batch_Process_Log__c> blogs;
    private loan.GlobalLoanUtilFacade facade;
    private Date sysDate;
    
    /* Constructor */
    public LoanPaymentTransactionRetryJob() {
        
        facade = new loan.GlobalLoanUtilFacade();
        sysDate = facade.getCurrentSystemDate();
        
        this.query = ProcessJobQueryUtil.getRetryJobQuery(sysDate);
        
        loanPayments = new List<loan__Loan_Payment_Transaction__c>();
        bLogs = new List<loan__Batch_Process_Log__c>();
        
        pMode = [Select Id,Name from loan__Payment_Mode__c Where Name = 'ACH' limit 1];
    
    }
    
    public void execute(SchedulableContext sc) {
        
    }
        
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        
        List<Payment_Retry__c> retryTxns = (List<Payment_Retry__c>) scope;
        loan__Loan_Payment_Transaction__c lptToCreate;
        
        Savepoint sp = Database.setSavepoint();
        try{
        
            for(Payment_Retry__c retry : retryTxns) {
                lptToCreate = getNewLoanPayment(retry);
                loanPayments.add(lptToCreate);
                
                retry.Retry_Attempted__c = true;
                retry.Retry_Attempted_On__c = sysDate;
                
            }
            
            //insert loan payments
            insert loanPayments;
            
            //update retry attempted flag on retry order
            update retryTxns;
        }catch(Exception e) {
            Database.rollback(sp);
            loan__Batch_Process_Log__c errorLog = new loan__Batch_Process_Log__c();
            errorLog.loan__Message__c = 'Error : LoanPaymentTransactionRetryJob: '+e.getMessage()+' from line '+e.getLineNumber();
            errorLog.loan__Date__c = Date.newInstance(System.now().year(),System.now().month(),System.now().day());
            
            bLogs.add(errorLog);
            insert bLogs;
        }
    }
    @TestVisible 
    private loan__Loan_Payment_Transaction__c getNewLoanPayment(Payment_Retry__c rec) {
        loan__Loan_Payment_Transaction__c retVal = new loan__Loan_Payment_Transaction__c();
        
        retVal.loan__Transaction_Date__c = rec.Transaction_Date__c;
        retVal.loan__Transaction_Amount__c = rec.Debit_Amount__c;
        retVal.loan__Payment_Mode__c = pMode.Id;
        retVal.loan__Loan_Account__c = rec.CL_Contract__c;
        retVal.loan__Receipt_Date__c = rec.Transaction_Date__c;
        retVal.Payment_Type__c = 'Retry';
        
        return retVal;
    }
    
    
    public void finish(Database.BatchableContext bc){
    
    }
}