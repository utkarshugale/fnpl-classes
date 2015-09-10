public class LoanPaymentTransactionAchJob implements Database.Batchable<sObject>, Schedulable {
    private String query;
    private List<loan__Loan_Account_Due_Details__c> bills;
    private List<loan__Loan_Payment_Transaction__c> loanPayments;
    private loan__Payment_Mode__c pMode;
    private List<loan__Batch_Process_Log__c> blogs;
    
    /* Constructor */
    public LoanPaymentTransactionAchJob() {
        this.query = ProcessJobQueryUtil.getCustomACHLoc();
        
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
       
        bills = (List<loan__Loan_Account_Due_Details__c>) scope;
        loan__Loan_Payment_Transaction__c lpt;
        loan__Batch_Process_Log__c errorLog;
        
        try{
            for(loan__Loan_Account_Due_Details__c due : bills){
                lpt = new loan__Loan_Payment_Transaction__c();
                lpt.loan__Transaction_Date__c = due.loan__Due_Date__c;
                lpt.loan__Transaction_Amount__c = due.loan__Due_Amt__c;
                lpt.loan__Payment_Mode__c = pMode.Id;
                lpt.loan__Loan_Account__c = due.loan__Loan_Account__c;
                lpt.loan__Skip_Validation__c = true;
                
                System.debug(LoggingLevel.ERROR,' Transaction Date '+lpt.loan__Transaction_Date__c);
                
                loanPayments.add(lpt);
            }
            
            insert loanPayments;
            
            for(loan__Loan_Account_Due_Details__c due : bills) {
                due.Payment_Created__c = true;
            }
            
            update bills;
        }catch(Exception e) {
            errorLog = new loan__Batch_Process_Log__c();
            errorLog.loan__Message__c = 'Error : LoanPaymentTransactionAchJob: '+e.getMessage()+' from line '+e.getLineNumber();
            errorLog.loan__Date__c = Date.newInstance(System.now().year(),System.now().month(),System.now().day());
            
            bLogs.add(errorLog);
            insert bLogs;
        }
    }
    
    public void finish(Database.BatchableContext bc){
    
    }
}