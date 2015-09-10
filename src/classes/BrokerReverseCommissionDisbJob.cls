public class BrokerReverseCommissionDisbJob implements Database.Batchable<sObject>, Schedulable {
    private String query;
    private List<loan__Batch_Process_Log__c> blogs;
    private loan.GlobalLoanUtilFacade facade;
    private Date sysDate;
    private List<loan__Loan_Account__c> loans;
    
    /* Constructor */
    public BrokerReverseCommissionDisbJob() {
        facade = new loan.GlobalLoanUtilFacade();
        sysDate = facade.getCurrentSystemDate();
        this.query = ProcessJobQueryUtil.getBrokerCommissionJobQuery(sysDate);
        
        bLogs = new List<loan__Batch_Process_Log__c>();
        
    }
    
    public void execute(SchedulableContext sc) {
        
    }
        
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        loans = (List<loan__Loan_Account__c>) scope;
        
        try{
            BrokerReverseCommissiondisbJobHandler handler = new BrokerReverseCommissiondisbJobHandler(loans);
            handler.process();
        }catch(Exception e) {
            loan__Batch_Process_Log__c errorLog = new loan__Batch_Process_Log__c();
            errorLog.loan__Message__c = 'Error : LoanPaymentTransactionAchJob: '+e.getMessage()+' from line '+e.getLineNumber();
            errorLog.loan__Date__c = Date.newInstance(System.now().year(),System.now().month(),System.now().day());
            
            bLogs.add(errorLog);
            insert bLogs;
        }
    }
    
    public void finish(Database.BatchableContext bc){
    
    }
}