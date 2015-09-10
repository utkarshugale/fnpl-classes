public with sharing class CnpLoanPaymentController {
    
    loan__Payment_Mode__c cashPaymentMode;
    loan__Payment_Mode__c excessPaymentMode,cnpPaymentMode;
    public List<loan__Loan_account_Due_Details__c> listOfDues {get;set;} 
    private String param {get;set;}
    private loan__Loan_Account__c lAccount{get;set;}
    public Integer flag {get;set;}
    
    //To make transaction amount read-only
    public Boolean excessSelected {get; set;}
    public Boolean cnpSelected {get;set;}
    public loan__Bank_Account__c cnpBank{get;set;}
    public String expiryDetails{get;set;}
    public loan__Loan_Account__c loanAccount {get;set;}
    public loan__Loan_Payment_Transaction__c loanPayment {get;set;}
    private loan__Office_Name__c currentBranch;
    private Date systemDate;
    
    public CnpLoanPaymentController(ApexPages.StandardController controller) {
        cnpSelected = false;
        cnpBank = new loan__Bank_Account__c();
        List<loan__Payment_Mode__c> paymentModes = [SELECT ID, Name FROM loan__Payment_Mode__c WHERE Name=:loan.LoanConstants.LOAN_PAYMENT_MODE_CASH
                                             or Name =:loan.LoanConstants.LOAN_PAYMENT_MODE_EXCESS
                                             or Name = 'CNP'];
        
        //Populate Payment Modes.
        for(loan__Payment_Mode__c paymentMode : paymentModes) {
            if(paymentMode.Name.equalsIgnoreCase(loan.LoanConstants.LOAN_PAYMENT_MODE_CASH)) {
                cashPaymentMode = paymentMode;
            }
            else if(paymentMode.Name.equalsIgnoreCase(loan.LoanConstants.LOAN_PAYMENT_MODE_EXCESS)) {
                excessPaymentMode = paymentMode;
            }else if(paymentMode.Name.equalsIgnoreCase('CNP')){
                cnpPaymentMode = paymentMode;
            }
        }                                            
        excessSelected = false;
        
        //Get current System Date
        loan.GlobalLoanUtilFacade f = new loan.GlobalLoanUtilFacade();
        systemDate = f.getCurrentSystemDate();
        
        loanPayment = (loan__Loan_Payment_Transaction__c) controller.getRecord();
        
        //Initialize all nulls to avoid null pointer.
        initNullsToZero(loanPayment);
        
        param = ApexPages.currentPage().getParameters().get('loanId');
        
        if (param != null) {
            Id loanAccId = param;
            Date oldestDueDate = [SELECT loan__Oldest_Due_Date__c FROM loan__Loan_Account__c WHERE ID=:loanAccId LIMIT 1].loan__Oldest_Due_Date__c;
            loanAccount = [select Id,Name,
                                loan__Principal_Remaining__c,
                                loan__Expected_Disbursal_Date__c,
                                loan__Previous_Installment_Date__c,
                                loan__Amount_to_Current__c,  
                                loan__Fees_Remaining__c,
                                loan__Interest_Remaining__c,
                                loan__Interest_Accrued_Not_Due__c,
                                loan__Excess__c,
                                loan__Loan_Status__c,
                                loan__Product_Type__c,
                                loan__Payment_Application_Mode__c,
                                (SELECT Name,
                                 loan__Balance_Amount__c,
                                 loan__DD_Primary_Flag__c, 
                                 loan__Tolerance__c,
                                 loan__Transaction_Date__c
                                 FROM loan__Dues_Details__r
                                 WHERE loan__DD_Primary_Flag__c = true and loan__Due_Date__c=:oldestDueDate),
                                (SELECT Id, 
                                    Name, 
                                    loan__Date__c,
                                    loan__Fee__r.loan__Time_Of_Charge__c,
                                    loan__Total_Due_Amount__c
                                 FROM loan__Charges__r
                                 WHERE loan__Waive__c = false AND loan__Paid__c = false
                                 ORDER BY loan__Date__c ASC)
                            FROM loan__Loan_Account__c
                            WHERE Id = :loanAccId
                            limit 1];
            
            lAccount = [select Id, Name, loan__Loan_Status__c,
                                loan__Last_Transaction_Timestamp__c,
                                loan__Last_Transaction_Type__c 
                            from loan__Loan_Account__c
                            where Id = :param];
                            
            loanPayment.loan__Loan_Account__c = lAccount.Id;
        } else {
            Id loanAccId = loanPayment.loan__Loan_Account__c;
            Date oldestDueDate = [SELECT loan__Oldest_Due_Date__c FROM loan__Loan_Account__c WHERE ID=:loanAccId LIMIT 1].loan__Oldest_Due_Date__c;
            loanAccount = [select Id,Name,
                                loan__Principal_Remaining__c,
                                loan__Expected_Disbursal_Date__c,
                                loan__Previous_Installment_Date__c,
                                loan__Amount_to_Current__c,
                                loan__Interest_Remaining__c,
                                loan__Interest_Accrued_Not_Due__c,  
                                loan__Fees_Remaining__c,
                                loan__Excess__c,
                                loan__Loan_Status__c,
                                loan__Product_Type__c,
                                loan__Payment_Application_Mode__c,
                                loan__Contact__c,
                                (SELECT Name,
                                 loan__Balance_Amount__c,
                                 loan__DD_Primary_Flag__c, 
                                 loan__Tolerance__c,
                                 loan__Transaction_Date__c
                                 FROM loan__Dues_Details__r
                                 WHERE loan__DD_Primary_Flag__c = true and loan__Due_Date__c=:oldestDueDate),
                                (SELECT Id, 
                                    Name, 
                                    loan__Date__c,
                                    loan__Fee__r.loan__Time_Of_Charge__c,
                                    loan__Total_Due_Amount__c
                                 FROM loan__Charges__r
                                 WHERE loan__Waive__c = false AND loan__Paid__c = false
                                 ORDER BY loan__Date__c ASC)
                            FROM loan__Loan_Account__c
                            WHERE Id = :loanAccId
                            limit 1];
                        
        }                        
        loanPayment.loan__Payment_Application_Mode__c = loanAccount.loan__Payment_Application_Mode__c;
        loanPayment.loan__Payment_Mode__c = cnpPaymentMode.Id;
        cnpSelected = true;
        
        if (loanPayment.loan__Transaction_Date__c == null) {
            loanPayment.loan__Transaction_Date__c = systemDate;
        }
        
        if (loanPayment.id == null) { // means this is a new loan__Loan_Payment_Transaction__c
            //TODO: need to get the txn split in this case
            loanPayment.loan__Fees__c = loanAccount.loan__Fees_Remaining__c==null ? 0.0 : loanAccount.loan__Fees_Remaining__c;
            loanPayment.loan__Principal__c = 0.0;
            loanPayment.loan__Interest__c = 0.0;
        }
        loan__Loan_account_Due_Details__c due = null;
        if (loanAccount.loan__Dues_Details__r != null && loanAccount.loan__Dues_Details__r.size() > 0) {
            due = loanAccount.loan__Dues_Details__r.get(0);
        }
        
        if (loanPayment.loan__Transaction_Amount__c == 0.0) {
            if (loanAccount.loan__Amount_To_Current__c == 0.0) {
                if (due != null) {
                    loanPayment.loan__Transaction_Amount__c = due.loan__Balance_Amount__c;
                }
            } else {
                loanPayment.loan__Transaction_Amount__c = loanAccount.loan__Amount_To_Current__c;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 
                            'This account is in bad standing. The transaction amount has been adjusted to the amount to current.'));
            }
        }
    }
    
    public PageReference updateTransactionAmount(){
        loanPayment.loan__Transaction_Amount__c = loanPayment.loan__Fees__c + loanPayment.loan__Interest__c + loanPayment.loan__Principal__c;
        return null;
    }
    
    public PageReference setManualPaymentMode() {
        if(loanPayment.loan__Manual_Payment__c == true) {
           loanPayment.loan__Manual_Payment__c = false;
        }
        
        if(loanPayment.loan__Manual_Payment__c == false) {
            loanPayment.loan__Manual_Payment__c = true;
        }
        loanPayment.loan__Transaction_Amount__c = loanAccount.loan__Fees_Remaining__c==null ? 0.0 : loanAccount.loan__Fees_Remaining__c;
        return null;
    }
    
    public PageReference cancel() {
        return accountView();
    }
    
    public PageReference valid(){
        doValidate();
        return null;
    }
    
    public Boolean doValidate() {
        if((loanPayment.loan__Payment_Mode__c == cnpPaymentMode.Id)
            && ((cnpBank.Bank_Card_Details__c == null || String.isEmpty(cnpBank.Bank_Card_Details__c))
                || (cnpBank.Expiry_Month__c == null)
                || (cnpBank.Expiry_Year__c == null))){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Card Details are mandatory for \'CNP\' payment Mode.'));
            return false;        
        }
        
        if(loanPayment.loan__Manual_Payment__c && loanPayment.loan__Payment_Mode__c == excessPaymentMode.Id) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                            excessPaymentMode.Name + ' Payment Mode not allowed for a manual payment.'));
                return false;
        }
        //Added to restrict backdated payments till the last bill date.
        //Arjun
        if(loanAccount.loan__Previous_Installment_Date__c != null){
            if(loanAccount.loan__Product_Type__c.equalsIgnoreCase(loan.LoanConstants.LOC)){
                if(loanPayment.loan__Transaction_Date__c < loanAccount.loan__Previous_Installment_Date__c){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                                    ' Payment Date cannot be less than latest Bill date'));
                        return false;
                }
            }
        }
        else{
            if(loanPayment.loan__Transaction_Date__c < loanAccount.loan__Expected_Disbursal_Date__c){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                                ' Payment Date cannot be less than Disbursal date'));
                    return false;
            }
        }
        
        if (loanPayment.loan__Transaction_Amount__c == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                        'Transaction amount should be greater than zero.'));
            return false;
        }
        if(loanPayment.loan__Write_Off_Recovery_Payment__c && loanPayment.loan__Transaction_Amount__c > loanAccount.loan__Principal_Remaining__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                        'Transaction amount should not be greater than Principal remaining for Writeoff recovery payment.'));
            return false;
        }
        if (loanPayment.loan__Manual_Payment__c) {
           
            Decimal total = loanPayment.loan__Principal__c + loanPayment.loan__Interest__c + loanPayment.loan__Fees__c;
            if (loanPayment.loan__Transaction_Amount__c != total) {
                loanPayment.loan__Transaction_Amount__c = total;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 
                            'The transaction amount has been adjusted to sum off the spread.'));
               // return false;
            }
            
            if(loanPayment.loan__Principal__c > loanAccount.loan__Principal_Remaining__c) { 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                            'Principal amount greater than Principal Remaining, extra amount will be considered as excess.'));
                
            } 
            if(loanPayment.loan__Interest__c > (loanAccount.loan__Interest_Remaining__c + loanAccount.loan__Interest_Accrued_Not_Due__c)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                            'Interest amount greater than Interest Due, extra amount will be considered as excess.'));
                
            }
            
            if(loanPayment.loan__Fees__c > (loanAccount.loan__Fees_Remaining__c)) {
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                            'Fee amount greater than Fee Due, extra amount will be considered as excess.')); 
                
            }
        }
        
        if(loanPayment.loan__Payment_Mode__c == excessPaymentMode.Id && isLoanClosed()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 
                            excessPaymentMode.Name + ' Payment Mode not allowed for a closed loan.'));
                
        }
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 
                            'Valid!'));
        return true;
    }
    
    private Boolean isLoanClosed() {
        if(loanAccount.loan__Loan_Status__c.equalsIgnoreCase(loan.LoanConstants.LOAN_STATUS_CLOSED_OBLIGATIONS_MET) || 
            loanAccount.loan__Loan_Status__c.equalsIgnoreCase(loan.LoanConstants.LOAN_STATUS_CLOSED_WRITTEN_OFF) ||
            loanAccount.loan__Loan_Status__c.equalsIgnoreCase(loan.LoanConstants.LOAN_STATUS_CLOSED_RESCHEDULED)) {
            return true;
        }
        return false;
    }
    public PageReference accountView() {
        PageReference accPage = new ApexPages.StandardController(this.loanAccount).view();
        accPage.setRedirect(true);
        return accPage ;
    } 
    
    public PageReference save() {
        if (!doValidate()) {
           /* ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 
                            'Please confirm save.'));*/
            return null;
        }
        
        try{
            if (!loanPayment.loan__Manual_Payment__c) {
                // we make it 0, so that in presense of approval process
                // the wrong fee does not show before approval
                loanPayment.loan__Fees__c = 0.0;
            }
            
            //General Case : If CNP Payment mode is selected, Datacash should be called immediately. Payment will be inserted in Datacash API.
            if(loanPayment.loan__Payment_Mode__c == cnpPaymentMode.Id) {
                //get custom setting details to Send payment to Datacash
                Datacash_Config__c config = Datacash_Config__c.getOrgDefaults();
                
                if(config == null){
                    config = Datacash_Config__c.getInstance();
                }
                
                if(config == null){
                    throw new GeneralException('Datacash authentication details not found. Please check Custom Settings.');
                }
                
                String endPoint = config.Server_Url__c;
                String username = config.Username__c;
                String password = config.password__c;
                
                BorrowerImpl impl = new BorrowerImpl();
                String result = '';
                if(!Test.isRunningTest()){
                    result = impl.sendPaymentToDataCash(endpoint,username,password,cnpBank,loanPayment);
                }else{
                   result = 'SUCCESS'; 
                }
                if(result.equalsIgnoreCase('SUCCESS')) {
                    //Save New Card & deactivate old one.
                    List<loan__Bank_Account__c> cardsToUpdate = new List<loan__bank_account__c>();
                    List<loan__Bank_Account__c> oldCard = [Select Id,Name,
                                                                   loan__Active__c
                                                            From loan__Bank_account__c
                                                            Where loan__Contact__c =: loanAccount.loan__Contact__c
                                                            and loan__Active__c = true];
                                                            
                    if(cnpBank.loan__Active__c){
                        cnpBank.loan__Bank_Account_Number__c = cnpBank.Bank_Card_Details__c;
                        cnpBank.loan__Account_Usage__c = 'Borrower/Investor Account';
                        cnpBank.loan__Account_Type__c = 'Savings';
                        cnpBank.loan__Bank_Name__c = 'VISA';
                        cnpBank.loan__Contact__c = loanAccount.loan__Contact__c;
                        cardsToUpdate.add(cnpBank);
                        
                        if(!oldCard.isEmpty()){
                            oldCard[0].loan__Active__c = false;
                            cardsToUpdate.add(oldCard[0]);
                        }
                    }
                    
                    upsert cardsToUpdate;
                }else{
                    //do Nothing for now.
                }   
            }else {
                //Regular Payment.
                insert loanPayment;
            }
            
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Transaction successfully saved.'));
            PageReference accPage = new PageReference('/' + loanPayment.loan__Loan_Account__c);
            return accPage;
        }catch (DmlException dmlE) {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Validation error - ' + dmlE.getMessage()));
               return null;
        }catch (Exception lpe) {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error while recording payment - ' + lpe.getMessage()+' from line '+lpe.getLineNumber()));
               return null;
        }
        
    }
    
    private void initNullsToZero(loan__Loan_Payment_Transaction__c loanPayment) {
        if (loanPayment.loan__Transaction_Amount__c == null) {
            loanPayment.loan__Transaction_Amount__c = 0.0;
        }
        if (loanPayment.loan__Payment_Mode__c == null) {
            loanPayment.loan__Payment_Mode__c = cashPaymentMode.Id;
        }
        if (loanPayment.loan__Fees__c == null) {
            loanPayment.loan__Fees__c = 0.0; 
        }
        if (loanPayment.loan__Interest__c == null) {
            loanPayment.loan__Interest__c = 0.0;
        }
        if (loanPayment.loan__Principal__c == null) {
            loanPayment.loan__Principal__c = 0.0;
        }
    }
    
    public PageReference populateTransactionAmount() {
         excessSelected = false;  
         if(loanPayment.loan__Payment_Mode__c == excessPaymentMode.Id) {             
             excessSelected = true;
             loanPayment.loan__Transaction_Amount__c = loanAccount.loan__Excess__c;
         }
         
         if(loanPayment.loan__Payment_Mode__c == cnpPaymentMode.Id) {
             cnpSelected = true;
         }
         
         if(loanPayment.loan__Payment_Mode__c != cnpPaymentMode.Id) {
             cnpSelected = false;
         }
         return null;
    }   
}