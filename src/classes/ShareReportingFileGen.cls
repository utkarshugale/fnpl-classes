global class ShareReportingFileGen implements Schedulable, Database.Batchable<Sobject>,Database.Stateful {
    private String query;
    private static String NAME = 'SHARE FILE GENERATOR JOB';
    private loan.TransactionSweepToACHState state;
    private Date iDate;
    
    global ShareReportingFileGen() {
    
        String NonAllowabledLoanStatuses = '\'' + loan.LoanConstants.LOAN_STATUS_PARTIAL_APPLICATION + '\'' + ',' + 
                                        '\''+ loan.LoanConstants.LOAN_STATUS_PENDING_APPROVAL + '\'' + ',' + 
                                        '\''+ loan.LoanConstants.LOAN_STATUS_APPROVED + '\''+ ',' +
                                        '\''+ loan.LoanConstants.LOAN_STATUS_CANCELED +'\''+ ','+
                                        '\''+ loan.LoanConstants.LOAN_STATUS_CLOSED_RESCHEDULED +'\''+','+
                                        '\''+ loan.LoanConstants.LOAN_STATUS_DISBURSED_TO_LO +'\'';
        
        query = 'Select Id,Name,'+
                        'loan__Contact__r.FirstName,'+
                        'loan__Contact__r.LastName,'+
                        'loan__Contact__r.suffix,'+
                        'loan__Contact__r.MiddleName,'+
                        'loan__Contact__r.salutation,'+
                        'loan__Contact__r.Birthdate,'+
                        'loan__Contact__r.MailingStreet,'+
                        'loan__Contact__r.MailingCity,'+
                        'loan__Contact__r.MailingState,'+
                        'loan__Contact__r.MailingPostalCode,'+
                        'loan__Disbursal_Date__c,'+
                        'loan__Loan_Status__c,'+
                        'loan__Last_Payment_Date__c,'+
                        'loan__Credit_Limit__c,'+
                        'loan__Pay_Off_Amount_As_Of_Today__c,'+
                        'loan__Term_Cur__c,'+
                        'loan__Frequency_of_Loan_Payment__c,'+
                        'loan__Metro2_First_Delinquency_Date__c,'+
                        'Delinquent_Amount_Snapshot__c,'+
                        'loan__Number_of_Days_Overdue__c,'+
                        'loan__First_Installment_Date__c,'+
                        'Flag__c,'+
                        'Current_Status__c'+
                ' From loan__Loan_Account__c '+
                ' WHERE loan__Loan_Status__c NOT IN ('+ NonAllowabledLoanStatuses +')';
                
        state = new loan.TransactionSweepToACHState();
    }
    
    global void execute(SchedulableContext sc) {
        ShareReportingFileGen j = new ShareReportingFileGen();
        Database.executeBatch(j);
    }
    
    global Database.Querylocator start(Database.BatchableContext bc) {
        System.debug(LoggingLevel.ERROR,' Query '+query);
        return Database.getQueryLocator(query);
    } // do nothing
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        if (scope.size() == 0) {
            return;
        }
        try {
            loan.FileGenerator filegen = new ShareInsightFormatGen();
            filegen.setScope(scope);
            filegen.createLines(state);
            String filename = filegen.writeFile(state);
            List<SObject> validScope = filegen.getValidScope();
            
        } catch (Exception e) {
            throw new GeneralException(e.getMessage()+' From line '+e.getLinenumber());
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }

}