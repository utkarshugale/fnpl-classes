public class LoanPaymentTransactionSweepToDatacash implements Database.Batchable<sObject>, Schedulable,  Database.AllowsCallouts {
    private String query;
    private List<loan__Loan_Payment_Transaction__c> loanPayments;
    private Map<Id,String> invalidPaymentsErrors;
    private List<loan__Loan_Payment_Transaction__c> validPayments;
    private List<loan__Loan_Payment_Transaction__c> rejectPayments;
    private loan__Payment_Mode__c pMode;
    private List<loan__Batch_Process_Log__c> blogs;
    private loan.GlobalLoanUtilFacade facade;
    private Date sysDate;
    private Map<Id,loan__Bank_Account__c> borrowerCardDetailsMap;
    private Datacash_Config__c config;
    
    /* Constructor */
    public LoanPaymentTransactionSweepToDatacash() {
        
        facade = new loan.GlobalLoanUtilFacade();
        sysDate = facade.getCurrentSystemDate();
        
        this.query = ProcessJobQueryUtil.getLoanPaymentTxnSweepToACHJobQuery(sysDate);
        
        invalidPaymentsErrors = new Map<Id,String>();
        validPayments = new List<loan__Loan_Payment_Transaction__c>();
        rejectPayments = new List<loan__Loan_Payment_Transaction__c>(); 
        borrowerCardDetailsMap = new Map<Id,loan__Bank_Account__c>();
        bLogs = new List<loan__Batch_Process_Log__c>();
        
        //get custom setting details to Send payment to Datacash
        config = Datacash_Config__c.getOrgDefaults();   
    
    }
    
    public void execute(SchedulableContext sc) {
        
    } 
        
    public Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('****Query****'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
       
        loanPayments = (List<loan__Loan_Payment_Transaction__c>) scope;
        loan__Batch_Process_Log__c errorLog;
        
        Set<ID> contactIds = new Set<ID>();
        
        //Prepare list of Borrowers & its Card Details.
        for(loan__Loan_Payment_Transaction__c lpt : loanPayments) {
            contactIds.add(lpt.loan__Loan_Account__r.loan__Contact__c);
        }
        
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
                                   Where Id in :contactIds];
        
        for(Contact c : borrowers) {
            if(c.loan__Bank_Accounts__r != null && !c.loan__Bank_Accounts__r.isEmpty()) {
                borrowerCardDetailsMap.put(c.Id,c.loan__Bank_Accounts__r[0]);
            }
        }
        
        //Send Payments To Datacash
        try{
            loan__Bank_Account__c activeCard;
            String endPoint = config.Server_Url__c;
            String username = config.Username__c;
            String password = config.password__c;
            
            BorrowerImpl impl = new BorrowerImpl();
            
            for(loan__Loan_Payment_Transaction__c lpt : loanPayments) {
                activeCard = borrowerCardDetailsMap.get(lpt.loan__Loan_Account__r.loan__Contact__c);
                
                if(activeCard == null) {
                    //Card details not found. Add to invalid transaction.
                    invalidPaymentsErrors.put(lpt.Id,' Active Card is not available for payments. Please contact borrower.');
                }else {
                    //Send to Datacash.
                    PaymentTransactionResponse payResponse = impl.sendPaymentToDataCashACH(endpoint,username,password,
                                                                                           activeCard,lpt);
                    
                    //If Response is success, 
                    if(payResponse.successMessage.equals('SUCCESS')
                        && (payResponse.lpt.Authorization_Code__c != null || 
                            !String.isEmpty(payResponse.lpt.Authorization_Code__c))) {
                        validPayments.add(payResponse.lpt);
                    } if(payResponse.lpt.Authorization_Code__c == null || 
                            String.isEmpty(payResponse.lpt.Authorization_Code__c)) {
                        rejectPayments.add(payResponse.lpt);   
                    }else {
                        invalidPaymentsErrors.put(lpt.Id,payResponse.responseBody);
                    }                                                                        
                }
            }
            
            //Create Batch Process logs for failed payments for any reason & update valid loanpayments
            //If valida payments are uncleared, clear them.
            for(loan__Loan_Payment_Transaction__c lpt : validPayments) {
                if(lpt.loan__cleared__c == false) {
                    lpt.loan__cleared__c = true;
                }
            }
            update validPayments;
            
            //reject payments
            for(loan__Loan_Payment_Transaction__c lpt : rejectPayments) {
               if(lpt.loan__cleared__c == false
                   && lpt.loan__Rejected__c == false
                   && lpt.loan__reversed__c == false) {
                    lpt.loan__Rejected__c = false;
                } 
            }
            
            for(loan__Loan_Payment_Transaction__c lpt : loanPayments) {
                
                if(invalidPaymentsErrors.get(lpt.Id) == null) {
                    continue;
                }else{
                    errorLog = new loan__Batch_Process_Log__c();
                    errorLog.loan__Message__c = 'Datacash processing failed for '+lpt.Name+'. Error: '+invalidPaymentsErrors.get(lpt.Id);
                    errorLog.loan__Date__c = Date.newInstance(System.now().year(),System.now().month(),System.now().day());
                    bLogs.add(errorLog);
                }
            }
            
            insert bLogs;
            
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