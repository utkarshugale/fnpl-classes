global class LineOfCreditExpiryJob implements Database.Batchable<sObject>, Schedulable {
    
    private static String NAME = 'LOC EXPIRY';
    private Date iDate;
    private Boolean submitNextJob = true;
    private loan.GlobalLoanUtilFacade facade;
    private String query;
    
    global LineOfCreditExpiryJob() {
        facade = new loan.GlobalLoanUtilFacade();
        iDate = facade.getCurrentSystemDate();
        
        query = ProcessJobQueryUtil.getLocExpiryQuery(iDate);
        System.debug(LoggingLevel.ERROR,' Query '+query);
    }
    
    global void execute(SchedulableContext sc) {
        LineOfCreditExpiryJob j = new LineOfCreditExpiryJob();
        Database.executeBatch(j);

    }
    
    global Database.querylocator Start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        List<loan__Loan_Account__c> locs = (List<loan__Loan_Account__c>)scope;
        
        //Expire Locs
        for(loan__Loan_Account__c loc : locs) {
            loc.Is_Expired__c = true;
            loc.loan__Invalid_Data__c = true;
            
            loc.loan__Loan_Status__c = 'Expired';
        }
        
        update locs;
    }
    
    global void finish(Database.BatchableContext bc){
    
    }
}