public class ProcessJobQueryUtil {
    
    public static String getSkinnyLoanObjectFields() {
        return 'Due_Day__c,' +
            'Write_off_Tolerance_Amount__c,' +
            'Loan_Status__c,' +
          'Product_Type__c, ' +
          'Discount__c, ' +
          'Discount_Applied_On__c, ' + 
          'Discounting_Based_Payoff__c, ' +            
            'Last_Accrual_Date__c,' +
            'Interest_Remaining__c,' +
            'Interest_Accrued_Not_Due__c,' +
            'Interest_Waived__c,' +
            'Frequency_of_Loan_Payment__c,' +
            'Interest_Calculation_Method__c,' +
            'Principal_Remaining__c,' +
            'Fees_Remaining__c,' +
            'Accrual_Stop_Indicator__c ,' +
            'Pay_Off_Amount_As_Of_Today__c,' +
            'Interest_Rate__c ,' +
            'Time_Counting_Method__c,' +
            'Next_Installment_Date__c,' +
            'Last_Installment_Date__c,' +
            'Next_Due_Generation_Date__c,' +
            'Maturity_Date_Current__c,' +
            'Last_Transaction_Timestamp__c,' +
            'last_transaction_id__c,' +
            'Pre_Bill_Days__c,' +
            'Last_Transaction_Type__c';
    }
 
 
    public static String getLoanPaymentTxnSweepToACHJobQuery(Date iDate) {
       
       String pMode = 'ACH';
       
       String retVal = 'Select Id,Name,'+
                               'loan__Loan_Account__c,'+
                               'loan__Loan_Account__r.loan__Contact__c,'+
                               'loan__cleared__c,'+
                               'loan__Rejected__c,'+
                               'loan__Reversed__c,'+
                               'loan__Transaction_Amount__c,'+
                               'loan__Transaction_Date__c,'+
                               'loan__Sent_To_Ach__c,'+
                               'loan__Sent_To_Ach_On__c,'+
                               'loan__Payment_Mode__c '+
                       ' From loan__Loan_Payment_Transaction__c '+
                       ' WHERE loan__Sent_To_Ach__c = false '+
                       ' AND loan__Payment_Mode__r.Name = \'' + pMode + '\'' + 
                       ' AND loan__Cleared__c = false '+
                       ' AND loan__Reversed__c = false '+
                       ' AND loan__Rejected__c = false '+
                       ' AND loan__Transaction_Date__c <= '+String.valueOf(iDate)+
                       ' ORDER BY loan__Transaction_Time__c DESC ';
    
        return retVal;        
    }

    public static String getLocExpiryQuery(Date iDate) {
        Id rtId = [Select Id From RecordType 
                   Where DeveloperName = 'Line_Of_Credit_Record_Type'
                   AND SObjectType = 'loan__Loan_Account__c'
                   AND NamespacePrefix = 'loan'].Id;
        
        String allowableStatus = '\'' + loan.LoanConstants.LOAN_STATUS_PARTIAL_APPLICATION + '\'' + ',' + 
                                        '\''+ loan.LoanConstants.LOAN_STATUS_PENDING_APPROVAL + '\'' + ',' + 
                                        '\''+ loan.LoanConstants.LOAN_STATUS_APPROVED + '\'';
                                        
        String sDate = String.valueOf(iDate);
        
        String retVal = 'Select Id,Name, ' +
                            'Expiry_Date__c, '+
                            'loan__Invalid_Data__c, '+
                            'Is_Expired__c, '+
                            'loan__Loan_Status__c,' +
                            'CreatedDate ' +
                        ' From loan__Loan_Account__c '+
                        ' Where loan__Loan_Status__c in (' + allowableStatus + ')'+
                        ' AND Expiry_Date__c < ' + sDate + 
                        ' AND loan__Invalid_Data__c = false ' +
                        ' AND Is_Expired__c = false ' +
                        ' AND RecordTypeId = '+ '\'' + rtId + '\'';
        
        System.debug(LoggingLevel.ERROR,' Query '+retVal);
                                                           
        return retVal;
    }
    
    public static String getCustomACHLoc() {
        String allowableStatus = '\'' + loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING + '\'' + ',' + 
                                        '\''+ loan.LoanConstants.LOAN_STATUSACTIVE_BAD_STANDING + '\'' + ',' + 
                                        '\''+ loan.LoanConstants.LOAN_STATUS_ACTIVE_MATURED + '\'';
                                        
        String retVal = 'Select Id, ' +
                            'loan__Loan_Account__c, '+
                            'loan__Balance_Amount__c, ' +
                            'Payment_Created__c, '+
                            'loan__Due_Amt__c, ' +
                            'loan__Due_Date__c, ' +
                            'loan__Due_Type_Description__c, ' +
                            'loan__Due_Type__c, ' +
                            'loan__Payment_Amt__c, ' +
                            'loan__Payment_Date__c, ' +
                            'loan__DD_Primary_Flag__c , '+
                            'loan__Payment_Satisfied__c, ' +
                            'loan__Tolerance__c, ' +
                            'loan__Transaction_Date__c ' +
                        'from  loan__Loan_Account_Due_Details__c ' +
                        'WHERE loan__DD_Primary_Flag__c = true and loan__Payment_Satisfied__c = false ' +
                        'and loan__Loan_Account__r.loan__Loan_Status__c in (' + allowableStatus + ') ' +
                        'and loan__Due_Type__c  = 1 '+
                        'and Payment_Created__c = false '+
                        'order by loan__Due_Date__c DESC';
        
        return retVal;
    
    }
    
    public static String getRefundJobQuery(Date iDate) {
        
        String retVal = 'Select Id,Name,'+
                                 'loan__Loan_Account__r.loan__Contact__c,'+
                                 'loan__Transaction_Amount__c,'+
                                 'loan__Loan_Account__c,'+
                                 'Datacash_Reference__c,'+
                                 'Merchant_Reference__c'+
                        ' From loan__Loan_Payment_Transaction__c '+
                        ' WHERE loan__Cleared__C = true '+
                        ' AND loan__Reversed__c = true '+
                        ' AND loan__Rejected__c = false '+
                        ' AND Refunded__c = false '+
                        ' AND loan__Sent_To_Ach__c = true '+
                        ' AND loan__Transaction_Date__c <= '+String.valueOf(iDate);
                        
        
        return retVal;
    }
    
    public static String getRetryJobQuery(Date iDate) {
        
        String retVal = 'Select Id,Name,' +
                               'CL_Contract__c, '+
                               'Debit_amount__c,'+
                               'Retry_Attempted__c,'+
                               'Retry_Attempted_On__c,'+
                               'Transaction_Date__c '+
                        ' From Payment_Retry__c '+
                        ' WHERE Retry_Attempted__c = false '+
                        ' AND Transaction_Date__c <= '+String.valueOf(iDate);
        
        return retVal;
    }
    
    public static String getBrokerCommissionJobQuery(Date iDate){
        
        String dateStr =String.valueOf(iDate); //= String.valueOf(iDate);
        
        String allowabledActiveLoanStatus = '\'' + loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING + '\'' + ',' + 
            '\''+ loan.LoanConstants.LOAN_STATUSACTIVE_BAD_STANDING + '\'' + ',' +  
            '\''+ loan.LoanConstants.LOAN_STATUS_ACTIVE_MATURED + '\'';
        
        String allowabledClosedLoanStatus = '\''+ loan.LoanConstants.LOAN_STATUS_CLOSED_OBLIGATIONS_MET + '\'';
        
        return 'SELECT ID, name,' +
            'loan__Frequency_of_Loan_Payment__c, ' +
            'loan__Term_Cur__c, ' +
            'loan__Interest_estimated__c, ' +
            'loan__Loan_Status__c, '+
            'loan__Pmt_Amt_Cur__c, ' +
            'loan__Contact__c, ' +
            'loan__Contact__r.Name, ' +
            'loan__Account__c, ' +
            'loan__Account__r.Name, ' +
            'loan__Pay_Off_Amount_As_Of_Today__c, '+
            'loan__Charged_Off_Fees__c, '+
            'loan__Charged_Off_Interest__c, '+
            'loan__Charged_Off_Principal__c, '+
            'loan__Previous_Installment_Date__c, '+
            'loan__Last_Payment_Date__c , '+
            'loan__Loan_Amount__c, ' +
            'loan__Principal_Remaining__c, '+
            'loan__Delinquent_Amount__c, '+
            'loan__Next_Commission_Payment_Date__c, '+
            'loan__Disbursal_Date__c, ' +
            'loan__Loan_Effective_Date__c, ' +
            ' (select id, '+  
                ' name, '+  
                ' loan__Account__c, '+
                ' loan__Contact__c, '+
                ' loan__Buy_Rate__c, '+  
                ' loan__Calculation_Method__c, '+  
                ' loan__Commission_Disbursement_Method__c, '+  
                ' loan__Commission_Amount__c, '+  
                ' loan__Factor__c, '+  
                ' loan__Flat_Amount__c, '+  
                ' loan__Maximum_Commission_Percentage__c, '+  
                ' loan__Upfront_Commission_Amount__c, '+
                ' loan__Plan_Description__c, '+  
                ' loan__Remaining_Commission_Amount_Funding__c, '+
                ' loan__Total_Commission_Paid_Amount__c, '+
                ' loan__Commission_Till_Date__c,'+
                ' loan__Last_Commission_Date__c, '+
                ' loan__Last_Principal_Used__c, '+
                ' loan__Upfront_Percentage__c, '+  
                ' loan__Next_Payment_Date__c, '+  
                ' loan__Last_Payment_Date__c '+  
            ' from loan__Brokers__r '+  
            ' where loan__enabled__c = true and loan__Reverse_Broker__c = true and '+
            ' loan__Next_Payment_Date__c < '+dateStr+' ), '+     //Made a change in the query here
            ' (select Id,Name, ' +
                    ' loan__Fees__c, ' +
                    ' loan__Interest__c, ' +
                    ' loan__Principal__c, ' +
                    ' loan__Excess__c, ' +
                    ' loan__Cleared__c, ' +
                    ' loan__Reversed__c, ' +
                    ' loan__Transaction_Amount__c, ' +
                    ' loan__Transaction_Time__c, '+
                    ' loan__Transaction_Date__c, ' +
                    ' loan__Payment_Mode__c, ' +
                    ' loan__payment_mode__r.name, ' +
                    ' loan__Rejected__c, ' +
                    ' loan__Paid_To_Broker__c, '+
                    ' CreatedDate ' +                                                    
            ' from loan__Loan_Payment_Transactions__r '+ 
            ' where loan__Paid_to_Broker__c = false '+
            ' and loan__Reversed__c = false '+
            ' and loan__Cleared__c = true and loan__Rejected__c = false) '+                                                                    
            'FROM Loan_Account__c ' +
            'WHERE ((loan__Loan_Status__c  IN (' + allowabledActiveLoanStatus + ') ) '+ 
            '    OR (loan__Loan_Status__c IN ('+allowabledClosedLoanStatus+')) )'+                
            ' and loan__Next_Commission_Payment_Date__c < ' + dateStr +   //Made a change in the query here             
            ' and loan__Invalid_Data__c = false ' +
            ' order by LastModifiedDate desc ';
    }    
}