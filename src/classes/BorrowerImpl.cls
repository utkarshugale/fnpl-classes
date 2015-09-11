public class BorrowerImpl {

    public Database.LeadConvertResult convertLead(Id leadId) {
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(true);
        lc.setSendNotificationEmail(true);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        return lcr;
    }
    
    public loan__Automated_Payment_Setup__c setUpACHonContract(loan__Loan_Account__c loanAcc,Date setupDate,String frequency,String achType,
                                                               loan__Payment_Mode__c pMode) {
        loan__Automated_Payment_Setup__c retVal = new loan__Automated_Payment_Setup__c();
        
        retVal.loan__CL_Contract__c = loanAcc.Id;
        retVal.loan__Setup_Date__c = setupDate;
        retVal.loan__Active__c = true;
        retVal.loan__Amount_Type__c = 'LAST BILLED AMOUNT';
        retVal.loan__Payment_Mode__c = pMode.Id;
        retVal.loan__Debit_Date__c = loanAcc.loan__Next_Installment_Date__c;
        retVal.loan__Recurring_ACH_Start_Date__c = loanAcc.loan__Next_Installment_Date__c;
        retVal.loan__Recurring_ACH_End_Date__c = loanAcc.loan__Next_Installment_Date__c.addMonths((Integer)loanAcc.loan__Term_Cur__c);
        retVal.loan__Frequency__c = (frequency == null || String.isempty(frequency)) ? 'Monthly' : frequency;
        retVal.loan__Type__c = achType;
        retVal.loan__Transaction_Amount__c = 0;
        
        insert retVal;
        
        return retVal;
    }
    
    private loan__Broker__c calculateCommission(loan__Loan_Account__c lAcc,loan__Broker__c loanBroker){
        system.debug(logginglevel.error,'-- calculateCommission(+) --');
        
        
        loanBroker.loan__Commission_Amount__c = getCommissionAmount(lAcc,loanBroker);
        
        if (loanBroker.loan__Commission_Amount__c > 0){
            loanBroker.loan__Commission_Amount__c = loan.ValueUtil.round(loanBroker.loan__Commission_Amount__c);
            loanBroker.loan__Upfront_Commission_Amount__c = loan.ValueUtil.round(loanBroker.loan__Commission_Amount__c * ((loanBroker.loan__Upfront_Percentage__c)/100));
            loanBroker.loan__Remaining_Commission_Amount_Funding__c = loanBroker.loan__Commission_Amount__c- loanBroker.loan__Upfront_Commission_Amount__c;
        }else{
            loanBroker.loan__Commission_Amount__c  = 0.00;
            loanBroker.loan__Remaining_Commission_Amount_Funding__c  = 0.00;
            loanBroker.loan__Upfront_Commission_Amount__c  = 0.00;
        }
        loanBroker.loan__Total_Commission_Paid_Amount__c = 0.00;
        
        system.debug(logginglevel.error,'-- Commission_Amount__c :'+loanBroker.loan__Commission_Amount__c);
        system.debug(logginglevel.error,'-- Upfront_Commission_Amount__c :'+loanBroker.loan__Upfront_Commission_Amount__c);
        system.debug(logginglevel.error,'-- Remaining_Commission_Amount_Funding__c :'+loanBroker.loan__Remaining_Commission_Amount_Funding__c);
        //update loanBroker;
        system.debug(logginglevel.error,'-- calculateCommission(-) --');
        
        return loanBroker;
    }
    
    public List<loan__Commission_Plan__c> getCommissionPlans() {
        List<loan__Commission_Plan__c> bPlan = [Select Id,Name,
                                                               loan__Buy_Rate__c,
                                                               loan__Calculation_Method__c,
                                                               loan__Commission_Disbursement_Method__c,
                                                               loan__Enabled__c,
                                                               loan__Factor__c,
                                                               loan__Flat_Amount__c,
                                                               loan__Maximum_Commission_Percentage__c,
                                                               loan__Plan_Description__c,
                                                               loan__Upfront_Percentage__c
                                                        From loan__Commission_Plan__c
                                                        Where loan__Enabled__c = true];
        return bPlan;
    }
    
    public loan__Broker__c setupBrokeragePlan(loan__Loan_Account__c loanAccount, Account broAcc,
                                           loan__Commission_Plan__c brokerPlan) {
        loan__Broker__c broker = new loan__Broker__c();
        
        broker.loan__Lending_Account__c = loanAccount.Id;
        broker.loan__Account__c = broAcc.Id;
        broker.loan__Commission_Plan__c = brokerPlan.Id;
        broker.loan__Buy_Rate__c = 0;
        broker.loan__Calculation_Method__c = brokerplan.loan__Calculation_Method__c;
        broker.loan__Plan_Description__c = brokerplan.loan__Plan_Description__c;
        broker.loan__Maximum_Commission_Percentage__c = brokerplan.loan__Maximum_Commission_Percentage__c;
        broker.loan__Upfront_Percentage__c = brokerplan.loan__Upfront_Percentage__c;
        broker.loan__Factor__c = brokerPlan.loan__factor__c;
        broker.loan__Commission_Disbursement_Method__c = brokerPlan.loan__Commission_Disbursement_Method__c;
        
        try{
            broker = calculateCommission(loanAccount,broker); 
            insert broker;      
        }catch (Exception e){
            throw e;
        }
        
        return broker;
    }
     
     private Decimal getCommissionAmount(loan__Loan_Account__c loanAccount, loan__Broker__c broker){
        system.debug(logginglevel.error,'-- getCommissionAmount() --');
        Decimal commissionAmount = 0;
        system.debug(logginglevel.error,'-- Calculate Commission for Broker : ' + broker);
        system.debug(logginglevel.error,'-- Calculation_Method__c : ' + broker.loan__Calculation_Method__c);
        if (broker.loan__Calculation_Method__c == loan.LoanConstants.FLAT){
            commissionAmount = broker.loan__Flat_Amount__c;
        } 
        else if (broker.loan__Calculation_Method__c == loan.LoanConstants.PER_FIN_AMOUNT){
           
            commissionAmount = (((loanAccount.loan__loan_amount__c) * (broker.loan__Maximum_Commission_Percentage__c/100))*(broker.loan__Factor__c/100));
        } 
        else if (broker.loan__Calculation_Method__c == loan.LoanConstants.SPREAD){
            Decimal buyRate = broker.loan__Buy_Rate__c;
            Decimal maxCommission = broker.loan__Maximum_Commission_Percentage__c;
            Decimal interestRate = loanAccount.loan__Contractual_Interest_Rate__c;
            if ((loanAccount.loan__Contractual_Interest_Rate__c- buyRate) >0){
                loan__FinancialCalculator__c calc  = new loan__FinancialCalculator__c();
                if ((loanAccount.loan__Contractual_Interest_Rate__c - buyRate) > (maxCommission)){
                    calc.loan__Rate__c = broker.loan__Maximum_Commission_Percentage__c;
                }else{
                    calc.loan__Rate__c = (loanAccount.loan__Contractual_Interest_Rate__c - buyRate);
                }
                calc.loan__Contract_Dt__c = loanAccount.loan__Expected_Disbursal_Date__c;
                calc.loan__First_Payment_Dt__c = loanAccount.loan__Expected_Repayment_Start_Date__c;
                calc.loan__Loan_Amt__c  = loanAccount.loan__loan_amount__c;
                calc.loan__Original_Loan_Amt__c = loanAccount.loan__loan_amount__c;   
                calc.loan__Prepaid_Fees__c  = 0.00;
                calc.loan__Financed_Fees__c  = 0.00;
                calc.loan__Term__c  = (Integer)loanAccount.loan__Number_of_Installments__c;
                calc.loan__Accrual_Base_Method_Cd__c  = (loanAccount.loan__Time_Counting_Method__c ==loan.LoanConstants.TIME_COUNTING_ACTUAL_DAYS)?loan.LoanConstants.LOAN_ACCRUAL_METHOD_CD_365_365:loan.LoanConstants.LOAN_ACCRUAL_METHOD_CD_360_360;
                calc.loan__Balloon_Method_Cd__c  = 'DUMMY';
                calc.loan__Time_Counting_Method_Cd__c  = (loanAccount.loan__Time_Counting_Method__c ==loan.LoanConstants.TIME_COUNTING_ACTUAL_DAYS)?loan.LoanConstants.TIME_COUNTING_ACTUAL_DAYS:loan.LoanConstants.TIME_COUNTING_MONTH_AND_DAYS;
                calc.loan__Balloon_Payment_Amt__c  = (loanAccount.loan__Balloon_Payment__c == null)?0:loanAccount.loan__Balloon_Payment__c;
                calc.loan__Payment_Frequency_Cd__c  = loanAccount.loan__Frequency_of_Loan_Payment__c;
                calc.loan__Payment_Amt__c = 0;
                calc.loan__Interest_Amt__c = 0;
                calc.loan__Financed_Amt__c = 0;
                calc.loan__Balance_Amt__c = 0;
                calc.loan__First_Period_Calender_Days__c = 0;
                calc.loan__First_Period_Interest__c = 0;
                calc.loan__APR__c = 0;
                calc.loan__Total_Financed_Amt__c = 0;
                calc.loan__Total_Finance_Charge__c = 0;
                calc.loan__Total_Of_Payments__c = 0;
                calc.loan__Action__c = 'CALCULATE_ALL';
                calc.loan__Amortization_Calculation_Method_Cd__c = 'NONE';
                calc.loan__Additional_Interest_Amt__c = 0;
                calc.loan__Final_Payment_Amt__c = 0;
                calc.loan__Installment_Method_Cd__c = 'UNDEFINED';
                calc.loan__Flexible_Repayment_Flag__c = False;
                calc.loan__Interest_Only_Period__c = 0;
                calc.loan__Repayment_Type_Cd__c = 'UNDEFINED';
                calc.loan__Billing_Method_Cd__c = loanAccount.loan__Interest_Calculation_Method__c;
                calc.loan__Principal_Payment_Amt__c = 0;
                calc.loan__First_Payday_Date__c = loanAccount.loan__First_Installment_Date__c;
                calc.loan__Second_Payday_Date__c = loanAccount.loan__Second_Installment_Date__c;                
                
                List<loan__Multi_Step_Loan_Setup__c> rateschedule = new List<loan__Multi_Step_Loan_Setup__c>();
                if(calc.loan__Billing_Method_Cd__c.equals(loan.LoanConstants.REPAYMENT_INT_CALC_METHOD_FLEXIBLE_REPAYMENT)){
                    rateschedule = [select Id
                                         , loan__Sequence__c
                                         , loan__Interest_Rate__c
                                         , loan__Start_Date__c
                                      from loan__Multi_Step_Loan_Setup__c
                                     where loan__Loan_Account__c = :loanAccount.Id
                                     order by loan__Sequence__c asc];         
                } 
                List<loan.EMI> emiList = loan.FinancialCalc2.calculateEMI(calc,rateschedule);
                commissionAmount = calc.loan__Interest_Amt__c;
            }else{
                commissionAmount = 0.00;
            }
        }
        
        //Added to calculate commission for annual percentage
        else if(broker.loan__Calculation_Method__c.equalsIgnoreCase('Annual Percentage')){
            commissionAmount = (broker.loan__Maximum_Commission_Percentage__c / 100) * loanAccount.loan__Credit_Limit__c;
        }
        
        if (commissionAmount > 0){
            commissionAmount = loan.ValueUtil.round(commissionAmount);
        } else {
            commissionAmount= 0.00;
        }
        return commissionAmount;
    }   

    public loan__Loan_Disbursal_Transaction__c disburseLocAccount(Date transactionDate, 
                                                                  Decimal amount,loan__Loan_Account__c loan,
                                                                   String merchantReference,
                                                                   String fundingReference){
        loan__Loan_Disbursal_Transaction__c loanDis;
        try{
            loanDis = new loan__Loan_Disbursal_Transaction__c();
            loanDis.loan__Loan_Account__c = loan.Id;
            loanDis.loan__Mode_of_Payment__c = [Select Id,Name from loan__Payment_Mode__c Where Name = 'Wire'].Id;
            loanDis.loan__Disbursed_Amt__c = amount;
            loanDis.loan__Disbursal_Date__c = transactionDate;
            loanDis.Partner__c = merchantReference;
            loanDis.Email_to_Send_Notification__c = loan.loan__Contact__r.Email;
            loanDis.Funding_Account_Reference__c = fundingReference;
            
            insert loanDis;
            
            
            loan__Disbursal_Txn_Distribution__c disTxn = new loan__Disbursal_Txn_Distribution__c();
            disTxn.loan__Distribution_Type__c = 'Disbursement';
            disTxn.loan__Loan_Disbursal_Transaction__c = loanDis.Id;
            disTxn.loan__Reference__c = loan.id;
            disTxn.loan__Distribution_Amount__c = amount;
            
            insert disTxn;     
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,' Error while disbursing LOC '+e.getMessage()+' from line '+e.getLineNumber());
            throw e;
        }
        
        return loanDis;
    }
    
    public loan__Loan_Account__c createLocAccount(Id borrowerId,
                                                   Id loanProductId,
                                                   Decimal loanAmount, 
                                                   Integer term,
                                                   Decimal interestRate,
                                                   String purpose,
                                                   Date disbursalDate,
                                                   Date firstInstallmentDate,
                                                   String frequencyOfPayment,
                                                   Integer interestOnlyPeriod, 
                                                   Decimal balloonPayment,
                                                   Boolean ach,
                                                   Id bankId,
                                                   Decimal interestRatePM,
                                                   Decimal loanApr,
                                                   Decimal creditScore,
                                                   String creditScoreType) {
        //Savepoint sp = Database.setSavepoint();
        try {
            Id branchId = [SELECT Id FROM loan__Office_Name__c limit 1].Id;  
            
            loan__Loan_Product__c lProduct = [Select Id,Name,
                                                     loan__Draw_Billing_Method__c,
                                                     loan__Draw_Period_Billing_Method__c,
                                                     loan__Draw_Period_Interest_Calculation__c,
                                                     loan__Draw_Term_Payment_Percent__c,
                                                     loan__Repayment_Billing_Method__c,
                                                     loan__Repayment_Period_Interest_Calculation__c,
                                                     loan__Repayment_Procedure__c,
                                                     loan__Repayment_Term_Payment_Percent__c
                                              From loan__Loan_Product__c
                                              Where Id =: loanProductId];
                                                            
            
            loan__Loan_Account__c retVal = new loan__Loan_Account__c(
                                            loan__Branch__c = branchId,
                                            loan__Loan_Product_Name__c = loanProductId,
                                            loan__Contact__c = borrowerId,
                                            loan__Credit_Limit__c = loanAmount,
                                            loan__Number_of_Installments__c = term,
                                            loan__Draw_term__c = term,
                                            loan__Accrue_Past_Maturity__c = true,
                                            loan__Repayment_Billing_Method__c = lProduct.loan__Repayment_Billing_Method__c,
                                            loan__Draw_Billing_Method__c = lProduct.loan__Draw_Billing_Method__c,
                                            loan__Expected_Disbursal_Date__c = disbursalDate,
                                            loan__Draw_Term_Payment_Percent__c = lProduct.loan__Draw_Term_Payment_Percent__c,
                                            loan__Repayment_Term_Payment_Percent__c = lProduct.loan__Repayment_Term_Payment_Percent__c,
                                            loan__Expected_Repayment_Start_Date__c = firstInstallmentDate,
                                            loan__Next_Installment_Date__c = firstInstallmentDate
                                            ); 
                                                                              
            List<loan__Loan_Purpose__c> loanPurpose = 
                            [SELECT Id FROM loan__Loan_Purpose__c WHERE Name = :purpose LIMIT 1];
            
            if(loanPurpose.size() > 0) {
                retVal.loan__Loan_Purpose__c = loanPurpose.get(0).id;
            }
            
            Id rt = [SELECT ID, Name 
                     FROM RecordType 
                     WHERE DeveloperName = 'Line_Of_Credit_Record_Type' 
                     AND sObjectType = 'loan__Loan_Account__c'].Id;
                     
            //get Loan Product
            mfiflexUtil.ExecutionContext ec = mfiflexUtil.ExecutionContext.getExecContext();
            mfiflexUtil.ObjectCache lpOC = ec.createObject('lpforwebservice',
                                                            'loan__Loan_Product__c');
    
            String s = null;
            lpOC.addFields(s);
            lpOC.addNamedParameter('lpid', loanProductId);
            lpOC.setWhereClause('ID = :lpid');
            lpOC.executeQuery();
            
            loan__Loan_Product__c lp = (loan__Loan_Product__c) lpOC.getRecords()[0];  
            
            retVal.loan__Loan_Status__c = loan.LoanConstants.LOAN_STATUS_PENDING_APPROVAL;
            retVal.loan__LA_Amortization_Enabled__c = FALSE;
            retVal.loan__Interest_Type__c = 'Fixed';
    
            retVal.RecordTypeId = rt;
              
            retVal.loan__Interest_Calculation_Method__c = lp.loan__Interest_Calculation_Method__c;        
            retVal.loan__Maximum_Draw_Amount__c = lp.loan__Maximum_Draw_Amount__c;
            retVal.loan__Minimum_Draw_Amount__c = lp.loan__Minimum_Draw_Amount__c;
            retVal.loan__Minimum_Due_Amount_On_Billing__c = 25;
            retVal.loan__Frequency_Of_Loan_Payment__c = frequencyOfPayment == null ? lp.loan__Frequency_Of_Loan_Payment__c : frequencyOfPayment;
            retVal.loan__Interest_Only_Period__c = interestOnlyPeriod == null ? lp.loan__Interest_Only_Period__c : interestOnlyPeriod;
            retVal.loan__Time_Counting_Method__c = lp.loan__Time_Counting_Method__c;
            retVal.loan__Delinquency_Grace_Days__c = lp.loan__Delinquency_Grace_Days__c;
            retVal.loan__Write_off_Tolerance_Amount__c = lp.loan__Write_off_Tolerance_Amount__c;
            retVal.loan__Grace_Period_for_Repayments__c = lp.loan__Late_Charge_Grace_Days__c;
            retVal.loan__Pre_Bill_Days__c = lp.loan__Pre_Bill_Days__c;
            retVal.loan__Interest_Rate__c = interestRate == null ? lp.loan__Default_Interest_Rate__c : interestRate;        
            retVal.loan__Balloon_Payment__c = balloonPayment == null ? 0 : balloonPayment;
            retVal.loan__Product_Type__c = lp.loan__Loan_Product_Type__c;
            retVal.loan__Overdue_Interest_Rate__c = lp.loan__Default_Overdue_Interest_Rate__c;
            retVal.loan__Fee_Set__c = lp.loan__Fee_Set__c;
    
            retVal.loan__Contractual_Interest_Rate__c = retVal.loan__Interest_Rate__c;
            retVal.loan__Disbursal_Date__c = retVal.loan__Expected_Disbursal_Date__c;
            retVal.loan__First_Installment_Date__c = retVal.loan__Expected_Repayment_Start_Date__c;
            retVal.loan__Contractual_Due_Day__c = retVal.loan__First_Installment_Date__c.day();
            retVal.loan__Last_Installment_Date__c = 
                            loan.DateUtil.addCycle(retVal.loan__First_Installment_Date__c, 
                                                (Integer) retVal.loan__First_Installment_Date__c.day(), 
                                                retVal.loan__Frequency_of_Loan_Payment__c, 
                                                (Integer) retVal.loan__Number_of_Installments__c - 1);
            
            //Custom fields
            retVal.Interest_Rate_PM__c = interestRatePM;
            retVal.Credit_Score__c = creditScore;
            retVal.Credit_Score_Type__c = creditScoreType;
            retVal.Loan_APR__c = loanApr;
            
            return retVal;
        } catch (Exception e) {
            //Database.rollback(sp);
            System.debug(e.getMessage());
            throw e;
        }
        return null;
    }
    
    public PaymentTransactionResponse sendPaymentToDataCashACH(String endpoint, String username, 
                                        String password, loan__Bank_Account__c bankDetails, 
                                        loan__Loan_Payment_Transaction__c lpt) {
        System.debug(LoggingLevel.ERROR,' Start Callout ');                                
        List<loan__Batch_Process_Log__c> bLogs;             
        PaymentTransactionResponse retVal = new PaymentTransactionResponse();
        
        //Form XML Request Body.
        DataCashUtil.PaymentRequest pReq = new DataCashUtil.PaymentRequest();
        pReq.username = username;
        pReq.password = password;
        pReq.cardNumber = bankDetails.Bank_Card_Details__c;
        pReq.expiryDate = bankDetails.Expiry_Month__c + '/' + bankDetails.Expiry_Year__c;
        pReq.amount = lpt.loan__Transaction_Amount__c+'';
        
        DataCashUtil d = new DataCashUtil();
        String requestBody = d.paymentXmlGenerator(pReq);
        
        //Get HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setBody(requestBody);
        req.setMethod('POST');
                
        //Make Http Call & get Response.
        HttpResponse response;
        String xmlBody;
        Dom.Document doc;
      
         try{
                 response = new Http().send(req);                               
                  }catch(Exception e){
                      if(test.isRunningTest()){
                          MockHttpLoanpaymentDatacash mc = new MockHttpLoanpaymentDatacash();
                         response = mc.respond(req);
                      }
                   system.debug('exception'+e.getMessage());
             }                                      
        
        
        if(response.getStatusCode() != 200) {
            retVal.errorMessage = 'FAILED';
            retVal.responseBody = response.getBody();
            
        }else {
            doc = response.getBodyDocument();
    
            //Retrieve the root element for this document.
            Dom.XMLNode xmlRes = doc.getRootElement();
            
            String mode = xmlRes.getChildElement('mode', null).getText();
            String reason = xmlRes.getChildElement('reason', null).getText();
            // print out specific elements
            System.debug(LoggingLevel.ERROR,'Mode: ' + mode);
            System.debug(LoggingLevel.ERROR,'Reason: ' + reason);
            
            if(reason.equalsIgnoreCase('ACCEPTED')) {
                lpt.loan__Sent_To_ACH__c = true;
                lpt.loan__Sent_To_ACH_ON__c = Date.newInstance(System.now().year(),system.now().month(),system.now().day());
                lpt.Datacash_Reference__c = xmlRes.getChildElement('datacash_reference',null).getText();
                lpt.Merchant_Reference__c = xmlRes.getChildElement('merchantreference',null).getText();
                lpt.Authorization_Code__c = (xmlRes.getChildElement('CardTxn',null) != null) ? 
                                                ((xmlRes.getChildElement('CardTxn',null).getChildElement('authcode',null) != null) ?
                                                xmlRes.getChildElement('CardTxn',null).getChildElement('authcode',null).getText() : 'authnull')
                                                : 'cardtxnnull';
            }else {
                String errorInformation = (xmlRes.getChildElement('information', null) != null ) ? xmlRes.getChildElement('information', null).getText()
                                           : null;
                retVal.errorMEssage = 'FAILED';                           
                retVal.responseBody  = errorInformation;
            }
            
            retval.lpt = lpt;
            retVal.successMessage = 'SUCCESS';
        }          
        
        return retVal;
        
    }
    
    public PaymentTransactionResponse sendPaymentToDataCashRefund(String endpoint, String username, 
                                              String password, loan__Bank_Account__c bankDetails, 
                                              loan__Loan_Payment_Transaction__c lpt) {
                                        
        List<loan__Batch_Process_Log__c> bLogs;
        loan_ix__API_Process_Logs__c apiLog;
        PaymentTransactionResponse retVal = new PaymentTransactionResponse();
        
        //Form XML Request Body.
        DataCashUtil.PaymentRequest pReq = new DataCashUtil.PaymentRequest();
        pReq.username = username;
        pReq.password = password;
        pReq.cardNumber = bankDetails.Bank_Card_Details__c;
        pReq.expiryDate = bankDetails.Expiry_Month__c + '/' + bankDetails.Expiry_Year__c;
        pReq.amount = lpt.loan__Transaction_Amount__c+'';
        pReq.method = 'refund';
        
        DataCashUtil d = new DataCashUtil();
        String requestBody = d.paymentXmlGenerator(pReq);
        
        //Get HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setBody(requestBody);
        req.setMethod('POST');
        req.setTimeout(120000);
                
        //Make Http Call & get Response.
        HttpResponse response;
        String xmlBody;
        Dom.Document doc;
        
        try{
            response = new Http().send(req);
            
            if(response.getStatusCode() != 200) {
                retVal.errorMessage = 'FAILED';
                retVal.responseBody = response.getBody();
                
            }else {
                doc = response.getBodyDocument();
        
                //Retrieve the root element for this document.
                Dom.XMLNode xmlRes = doc.getRootElement();
                
                String mode = xmlRes.getChildElement('mode', null).getText();
                String reason = xmlRes.getChildElement('reason', null).getText();
                // print out specific elements
                System.debug(LoggingLevel.ERROR,'Mode: ' + mode);
                System.debug(LoggingLevel.ERROR,'Reason: ' + reason);
                
                if(reason.equalsIgnoreCase('ACCEPTED')) {
                    lpt.Refunded__c = true;
                    lpt.Datacash_Reference__c = xmlRes.getChildElement('datacash_reference',null).getText();
                    lpt.Merchant_Reference__c = xmlRes.getChildElement('merchantreference',null).getText();
                    lpt.Authorization_Code__c = (xmlRes.getChildElement('CardTxn',null) != null) ? 
                                                ((xmlRes.getChildElement('CardTxn',null).getChildElement('authcode',null) != null) ?
                                                xmlRes.getChildElement('CardTxn',null).getChildElement('authcode',null).getText() : 'authnull')
                                                : 'cardtxnnull';
                }else {
                    String errorInformation = (xmlRes.getChildElement('information', null) != null ) ? xmlRes.getChildElement('information', null).getText()
                                               : null;
                    retVal.errorMEssage = 'FAILED';                           
                    retVal.responseBody  = errorInformation;
                }
                
                retval.lpt = lpt;
                retVal.successMessage = 'SUCCESS';
            }           
        }catch(Exception ie){
            blogs = new List<loan__Batch_Process_Log__c>();
            loan__Batch_Process_Log__c log = new loan__Batch_Process_Log__c();
            log.loan__Message__c = 'Error : CardAPI : issueVirtualCard '+ ie.getMessage();
            log.loan__Date__c = system.now().date();
            
            blogs.add(log);
            
            insert blogs;
            throw ie;
            
            retVal.errorMessage = 'FAILED';
        }
        
        return retVal;
        
    }
    
    public String sendPaymentToDataCash(String endpoint, String username, 
                                        String password, loan__Bank_Account__c bankDetails, 
                                        loan__Loan_Payment_Transaction__c lpt) {
                                        
        List<loan__Batch_Process_Log__c> bLogs;
        loan_ix__API_Process_Logs__c apiLog;
        String retVal;
        
        //Form XML Request Body.
        DataCashUtil.PaymentRequest pReq = new DataCashUtil.PaymentRequest();
        pReq.username = username;
        pReq.password = password;
        pReq.cardNumber = bankDetails.Bank_Card_Details__c;
        pReq.expiryDate = bankDetails.Expiry_Month__c + '/' + bankDetails.Expiry_Year__c;
        pReq.amount = lpt.loan__Transaction_Amount__c+'';
        
        DataCashUtil d = new DataCashUtil();
        String requestBody = d.paymentXmlGenerator(pReq);
        
        //Get HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setBody(requestBody);
        req.setMethod('POST');
        req.setTimeout(120000);
                
        //Make Http Call & get Response.
        HttpResponse response;
        String xmlBody;
        Dom.Document doc;
        
        try{
            response = new Http().send(req);
            
            if(response.getStatusCode() != 200) {
                retVal = 'FAILED';
              //  throw new loan_ix.IxarisException('API call to Datacash failed: '+response.getBody());
            }else {
                doc = response.getBodyDocument();
                
                System.debug(LoggingLevel.ERROR,' Response body '+doc);
        
                //Retrieve the root element for this document.
                Dom.XMLNode xmlRes = doc.getRootElement();
                
                String mode = xmlRes.getChildElement('mode', null).getText();
                String reason = xmlRes.getChildElement('reason', null).getText();
                String status = xmlRes.getChildElement('status',null).getText();
                // print out specific elements
                System.debug(LoggingLevel.ERROR,'Mode: ' + mode);
                System.debug(LoggingLevel.ERROR,'Reason: ' + reason);
                
                if(status.equalsIgnoreCase('1')) {
                    lpt.loan__Sent_To_ACH__c = true;
                    lpt.loan__Sent_To_ACH_ON__c = Date.newInstance(System.now().year(),system.now().month(),system.now().day());
                    lpt.Datacash_Reference__c = xmlRes.getChildElement('datacash_reference',null).getText();
                    lpt.Merchant_Reference__c = xmlRes.getChildElement('merchantreference',null).getText();
                    lpt.Authorization_Code__c = (xmlRes.getChildElement('CardTxn',null) != null) ? 
                                                ((xmlRes.getChildElement('CardTxn',null).getChildElement('authcode',null) != null) ?
                                                xmlRes.getChildElement('CardTxn',null).getChildElement('authcode',null).getText() : 'authnull')
                                                : 'cardtxnnull';
                }else {
                    String errorInformation = (xmlRes.getChildElement('information', null) != null ) ? xmlRes.getChildElement('information', null).getText()
                                               : null;
                    //throw new loan_ix.IxarisException(reason+ ' - ' +errorInformation+' ');
                }
                
                //Create log for API response.
                apiLog = new loan_ix__API_Process_Logs__c();
                apiLog.loan_ix__API_Reference__c = xmlRes.getChildElement('merchantreference',null).getText();
                apiLog.loan_ix__External_Call_Reference__c = lpt.Datacash_Reference__c;
                apiLog.Request_Body__c = response.getBody();
                apiLog.loan_ix__Http_Status_Code__c = 200;
                apiLog.loan_ix__Status__c = 'SUCCESSFUL';
                apiLog.Loan_Payment_Transaction__c = lpt.Id;
                
                insert apiLog;
                upsert lpt;
                
                retVal = 'SUCCESS';
            }          
        }catch(Exception ie){
            blogs = new List<loan__Batch_Process_Log__c>();
            loan__Batch_Process_Log__c log = new loan__Batch_Process_Log__c();
            log.loan__Message__c = 'Error : CardAPI : issueVirtualCard '+ ie.getMessage();
            log.loan__Date__c = system.now().date();
            
            blogs.add(log);
            
            insert blogs;
            throw ie;
            
            retVal = 'FAILED';
        }
        
        return retVal;
        
    }
}