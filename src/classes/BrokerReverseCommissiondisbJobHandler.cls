public class BrokerReverseCommissiondisbJobHandler {
    private List<loan__Loan_Account__c> loans;
    private List<loan__Loan_Account__c> loanAccToBeUpdatedList;
    private List<loan__Broker__c> brokerlistToBeUpdated;
    private List<loan__Broker_Transactions__c> brokerTransactionsToBeInserted;
    private List<loan__Loan_Payment_Transaction__c> PmtTxnsUpdateList ;
    private Date systemDate;
    
    public BrokerReverseCommissiondisbJobHandler(List<loan__Loan_Account__c> loans,Date systemDate) {
    
        this.loans = loans;
        this.brokerlistToBeUpdated = new List<loan__Broker__c>(); 
        this.PmtTxnsUpdateList = new List<loan__Loan_Payment_Transaction__c>();
        this.loanAccToBeUpdatedList = new List<loan__Loan_Account__c>();
        this.brokerTransactionsToBeInserted = new List<loan__Broker_Transactions__c>();
        this.systemDate = systemDate;
    }
    
    
    public void process() {
        System.debug(logginglevel.error,'Start Processing Broker commission List size'+loans.size());
        
        for(loan__Loan_Account__c loanAccount : loans){
            System.debug(logginglevel.error,'calling postBrokerCommission for:'+loanAccount.name);
            postBrokerCommission(loanAccount);
        }    
        
        System.debug(logginglevel.error,'brokerTransactionsToBeInserted: ' +brokerTransactionsToBeInserted.size());
        System.debug(logginglevel.error,'brokerlistToBeUpdated: ' +brokerlistToBeUpdated.size());
        System.debug('Updating the loan Account');
        
        update loanAccToBeUpdatedList;
        insert brokerTransactionsToBeInserted;
        update brokerlistToBeUpdated;
        update PmtTxnsUpdateList;
        
    }
    
    private void postBrokerCommission(loan__Loan_Account__c loanAccount){
        System.debug(logginglevel.error,'Processing : ' + loanAccount.name);
        
        List<loan__Broker__c> brokerSetupRecs = loanAccount.loan__Brokers__r;
        List<loan__Loan_Payment_Transaction__c> pmtTxnsList = loanAccount.loan__Loan_Payment_Transactions__r;
        Decimal totalCommissionEarned = 0;
        Decimal totalInterestEarned = 0;
        Decimal totalCommissionReversal = 0;
        Date nextCommPaymentDate = loan.LoanConstants.DT_MAX;
        
        System.debug(logginglevel.error,'brokerSetupRecs: ' + brokerSetupRecs);
        
        for(loan__Broker__c brokerSetup : brokerSetupRecs) {
            totalCommissionEarned = 0;
            totalCommissionReversal = 0;
            totalInterestEarned = 0;
            
            System.debug(logginglevel.error,'Commission_Disbursement_Method__c: ' + brokerSetup.loan__Commission_Disbursement_Method__c);
            
            if(brokerSetup.loan__Commission_Disbursement_Method__c.equalsIgnoreCase('Month End') 
                    || brokerSetup.loan__Commission_Disbursement_Method__c.equalsIgnoreCase('Quarterly') ) {
                System.debug('Inside Month End');
                if(loanAccount.loan__Loan_Status__c != loan.LoanConstants.LOAN_STATUSACTIVE_BAD_STANDING) {
                    totalCommissionEarned = brokerSetup.loan__Commission_Till_Date__c;
                    brokerSetup.loan__Commission_Till_Date__c = 0;
                    brokerSetup.loan__Last_Commission_Date__c = systemDate;
                    brokerSetup.loan__Last_Principal_Used__c = loanAccount.loan__Principal_Remaining__c;
                    
                    for(loan__Loan_Payment_Transaction__c pmtTxn : pmtTxnsList){
                        pmtTxn.loan__Paid_to_broker__c = true;
                        PmtTxnsUpdateList.add(pmtTxn);
                    }
                }else{
                    totalCommissionEarned = 0;
                }
            }
            
            totalCommissionEarned = loan.ValueUtil.round(totalCommissionEarned);
            System.debug(logginglevel.error,'totalCommissionEarned: ' + totalCommissionEarned);
            
            //  Total Commission Paid Amount
            if (totalCommissionEarned >0) {
                brokerSetup.loan__Total_Commission_Paid_Amount__c = (brokerSetup.loan__Total_Commission_Paid_Amount__c == null)?0:brokerSetup.loan__Total_Commission_Paid_Amount__c + totalCommissionEarned;
            }
            if (totalCommissionReversal >0){
                brokerSetup.loan__Total_Commission_Paid_Amount__c = (brokerSetup.loan__Total_Commission_Paid_Amount__c == null)?0:brokerSetup.loan__Total_Commission_Paid_Amount__c - totalCommissionReversal;
            }   
            System.debug(logginglevel.error,'brokerSetup.Total_Commission_Paid_Amount__c: ' + brokerSetup.loan__Total_Commission_Paid_Amount__c);
            
            //  Set Next Payment Date
            if (brokerSetup.loan__Commission_Disbursement_Method__c == loan.LoanConstants.PAY_AS_RECEIVED || brokerSetup.loan__Commission_Disbursement_Method__c.equalsIgnoreCase('Month End') ) {
                brokerSetup.loan__Last_Payment_Date__c = brokerSetup.loan__Next_Payment_Date__c;
                brokerSetup.loan__Next_Payment_Date__c = brokerSetup.loan__Next_Payment_Date__c.addMonths(1).toStartOfMonth().addDays(Date.daysInMonth(brokerSetup.loan__Next_Payment_Date__c.addMonths(1).toStartOfMonth().year(), brokerSetup.loan__Next_Payment_Date__c.addMonths(1).toStartOfMonth().month()) - 1);
            }else if(brokerSetup.loan__Commission_Disbursement_Method__c == loan.LoanConstants.UPFRONT_ME){
                brokerSetup.loan__Last_Payment_Date__c = brokerSetup.loan__Next_Payment_Date__c;
                brokerSetup.loan__Next_Payment_Date__c = loan.LoanConstants.DT_MAX;
            }
            //Added by Nachiketh for Quarterly
            else if(brokerSetup.loan__Commission_Disbursement_Method__c.equalsIgnoreCase('Quarterly')){
                brokerSetup.loan__Last_Payment_Date__c = brokerSetup.loan__Next_Payment_Date__c;
                brokerSetup.loan__Next_Payment_Date__c = brokerSetup.loan__Next_Payment_Date__c.addMonths(4).toStartofMonth().addDays(-1); 
            }
            System.debug(logginglevel.error,'brokerSetup.Next_Payment_Date__c: ' + brokerSetup.loan__Next_Payment_Date__c);
            // Commented by Simran - Next Commission Date on Loan Account will be set outside the for loop
            // loanAccount.Next_Commission_Payment_Date__c = (brokerSetup.Next_Payment_Date__c <loanAccount.Next_Commission_Payment_Date__c)?loanAccount.Next_Commission_Payment_Date__c:brokerSetup.Next_Payment_Date__c;
            
            // Added by Simran to get the minimum next payment date
            if (brokerSetup.loan__Next_Payment_Date__c < nextCommPaymentDate)
                nextCommPaymentDate = brokerSetup.loan__Next_Payment_Date__c;
            
            brokerlistToBeUpdated.add(brokerSetup);
            
            if (totalCommissionEarned > 0){
                loan__Broker_Transactions__c brokerTxn = new loan__Broker_Transactions__c(); 
                brokerTxn.loan__Transaction_Amount__c = totalCommissionEarned;
                brokerTxn.loan__Transaction_Date__c = systemDate;
                brokerTxn.loan__Reference__c = 'Commission disbursement for '+loanAccount.name;
                brokerTxn.loan__Transaction_Description__c = loan.loanConstants.TXN_COMMISSION_DISB;
                brokerTxn.loan__Transaction_Code__c = loan.loanConstants.TXN_COMMISSION_DISB;
                brokerTxn.loan__System_Created__c = true;
                brokerTxn.loan__Account__c = brokerSetup.loan__Account__c;
                brokerTxn.loan__Contact__c = brokerSetup.loan__Contact__c;
                brokerTxn.loan__Broker__c = brokerSetup.id;
                brokerTransactionsToBeInserted.add(brokerTxn);
            }else if (totalCommissionReversal !=0 ){
                loan__Broker_Transactions__c brokerTxn = new loan__Broker_Transactions__c(); 
                brokerTxn.loan__Transaction_Amount__c = totalCommissionReversal.abs();
                brokerTxn.loan__Transaction_Date__c = systemDate;
                brokerTxn.loan__Reference__c = 'Commission Chargeback for '+loanAccount.name;
                brokerTxn.loan__Transaction_Description__c = loan.loanConstants.TXN_COMMISSION_CGBK;
                brokerTxn.loan__Transaction_Code__c = loan.loanConstants.TXN_COMMISSION_CGBK;
                brokerTxn.loan__System_Created__c = true;
                brokerTxn.loan__Account__c = brokerSetup.loan__Account__c;
                brokerTxn.loan__contact__c = brokerSetup.loan__Contact__c;
                brokerTxn.loan__Broker__c = brokerSetup.id;
                brokerTransactionsToBeInserted.add(brokerTxn);
            }
            
        }
        // Added by Simran - set Next Commission Payment date on Loan Account
        System.debug(logginglevel.error,'nextCommPaymentDate: ' + nextCommPaymentDate );
        loanAccount.loan__Next_Commission_Payment_Date__c = nextCommPaymentDate ;
        loanAccToBeUpdatedList.add(loanAccount);
            
    }
    
}