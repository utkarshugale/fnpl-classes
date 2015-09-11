@RestResource(urlMapping='/v2/lineofcredit')
global class WSLocAccounts_v2 {

    public static BorrowerImpl b;
    
    @HttpPost
    global static Response createLoanAccount() {
        RestRequest req = RestContext.request;
        RestResponse restRes = RestContext.response;
        Response res = new Response();
        
        System.debug(LoggingLEvel.ERROR,' Request Received '+req);
        
        RequestBodyParser.RequestBodyParams reqParams = RequestBodyParser.getJsonParamsFromRequest(req);
        if(reqParams == null) {
            
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Unable to parse request';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        Map<String, Object> params = reqParams.getParams();
        String borrowerId = null;
        String loanProductId;
        ID bankId;
        Decimal loanAmount;
        Integer term;
        Decimal interestRate;
        String purpose;
        Date disbursalDate;
        Date firstInstallmentDate;
        String frequencyOfPayment;
        Integer interestOnlyPeriod;
        Decimal balloonPayment;   
        String partnerId;
        Boolean ach = false;
        Boolean isProductB = false;
        Decimal loanApr;
        Decimal interestRatePM;
        Decimal creditScore;
        String creditScoreType;
        
        b = new BorrowerImpl();
        
        try {
            if (params.get('borrowerId') != null) {
                borrowerId= (String)params.get('borrowerId');
            }
            if (params.get('loanProductId') != null) {
                loanProductId = (String)params.get('loanProductId');
            }            
            if (params.get('loanAmount') != null) {
                loanAmount = (Decimal)params.get('loanAmount');
            }
            if (params.get('term') != null) {
                term = (Integer)params.get('term');
            }
            if(params.get('interestRatePA') != null) {
                interestRate = (Decimal)params.get('interestRatePA');
            }
            if(params.get('purpose') != null) {
               purpose = (String)params.get('purpose');                
            }
            if(params.get('expectedDisbursalDate') != null) {
               disbursalDate = Date.valueOf((String)params.get('expectedDisbursalDate'));
            }
            if(params.get('firstInstallmentDate') != null) {
               firstInstallmentDate = Date.valueOf((String)params.get('firstInstallmentDate'));
            }
            if(params.get('frequencyOfPayment') != null) {
               frequencyOfPayment = (String)params.get('frequencyOfPayment');
            }
            if(params.get('interestOnlyPeriod') != null) {
               interestOnlyPeriod = (Integer)params.get('interestOnlyPeriod');
            }
            if(params.get('balloonPayment') != null) {
               balloonPayment = (Decimal)params.get('balloonPayment');
            }       
            system.debug('*****PartnerId'+(String)params.get('partnerId'));
            if(params.get('partnerId') != null) {
                partnerId = (String)params.get('partnerId');
            }
            if(params.get('loanApr') != null) {
                loanApr = (Decimal)params.get('loanApr');
            }
            if(params.get('interestRatePM') != null) {
                interestRatePM = (Decimal)params.get('interestRatePM');
            }
            if(params.get('creditScore') != null) {
                creditScore = (Decimal)params.get('creditScore');
            }
            if(params.get('creditScoreType') != null) {
                creditScoreType = (String)params.get('creditScoreType');
            }
            
        } catch(Exception e) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Unable to parse Request Params';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }

        if(borrowerId == null){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Account Id Null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        } else if(loanAmount == null || loanAmount == 0){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Loan Amount not valid';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        } else if(term == null || term == 0){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Term not valid';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        } 
        
        // Check if borrowerId is valid
        String fieldName = loan__API_Configuration__c.getOrgDefaults().loan__Account_Id_Field__c;
        if (fieldName == null) {
            fieldName = peer.Constants.DEFAULT_ID;
        } 
       
        System.debug(LoggingLevel.ERROR,' Contact Id '+borrowerId);
        
        //Convert Lead to Contact
        
        Database.LeadConvertResult lcr = b.convertLead(borrowerId);
        
        if(lcr.isSuccess()) {
            //replace borrowerId with new Contact Id.
            borrowerId = lcr.getContactId();
        }else {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = lcr.getErrors()[0].getMessage();
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        List<Contact> acc = [Select Id,Name,
                                    FirstName,
                                    LastName
                             From Contact Where Id =: borrowerId];
        
        if (acc.size() == 0) {
            //res.status = Constants.ERROR;
            //res.errorCode = Constants.ACCOUNT_NOT_FOUND;
            //restRes.statuscode = Constants.HTTP_BAD_REQUEST;
            //return res;

            //@author - Pankaj Jakhar
            res.errorCode = peer.Constants.CONTACT_NOT_FOUND;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Contact not found for given ID';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;

        } 
        
        //get loan Product Id
        loan__Loan_Product__c lp = [Select Id,Name,
                                           loan__Loan_Product_Type__c
                                    From loan__Loan_Product__c
                                    Where loan__Loan_Product_Type__c = 'Line of Credit' limit 1];
       

        //Disbursal Date
        loan.GlobalLoanUtilFacade f;
        If(!isProductB){
            f = new loan.GlobalLoanUtilFacade();
            disbursalDate = f.getCurrentSystemDate();
            firstInstallmentDate = disbursalDate.addDays(30);
        }else{
        
        }
        
        loan__Loan_Account__c lA = null;
        Virtual_Card__c vCard;
        Account broker;
        
        try {
            
            lA = b.createLocAccount(Id.valueOf(borrowerId),lp.Id, loanAmount, term, interestRate, 'Holiday', 
                                        disbursalDate,
                                        firstInstallmentDate, 'Monthly',0, 
                                        0,ach, bankId,interestRatePM,loanApr,creditScore,creditScoreType);
            
            insert lA;
            
            //If Partner Id is not null, Setup Brokerage.
            if(partnerId != null) {
                lA.Contract_Originated_From__c = 'Travel Partners';
                
                //fetch Broker
                List<Account> bList = [Select Id,NAme from Account Where Partner_Id__c =: partnerId];
                
                List<loan__Commission_Plan__c> bPlan = b.getCommissionPlans();
                
                if(bList != null && !bList.isEmpty()) {
                    broker = bList[0];
                }else{
                    res.errorMessage = 'Provided Travel Partner is not found. Please setup commission plan manually.';
                }
                
                b.setupBrokeragePlan(lA,broker,bPlan[0]);
            }
            
            lA.Expiry_Date__c = f.getCurrentSystemDate().addDays(30);
            update lA;
            
        } catch(Exception e) {
            
            res.errorCode = peer.Constants.API_EXCEPTION;
            res.errorMessage = e.getMessage()+' From line '+e.getLineNumber();
            res.status = peer.Constants.ERROR;
            restRes.statuscode = peer.Constants.HTTP_INTERNAL_ERROR;
            return res;  
        }
        
        res.content.add(lA);
        res.content.add(vCard);
        res.status = peer.Constants.SUCCESS;
        restRes.statuscode = peer.Constants.HTTP_OK;
        return res;
    }    
    
    /*
    private static loan__Broker__c calculateCommission(loan__Loan_Account__c lAcc,loan__Broker__c loanBroker){
        system.debug(logginglevel.error,'-- calculateCommission(+) --');
        
        
        loanBroker.loan__Commission_Amount__c = b.getCommissionAmount(lAcc,loanBroker);
        
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
    
    private static void setupBrokeragePlan(loan__Loan_Account__c loanAccount, Account broAcc,
                                           loan__Commission_Plan__c brokerPlan) {
        loan__Broker__c broker = new loan__Broker__c();
        
        broker.loan__Lending_Account__c = loanAccount.Id;
        broker.loan__Account__c = broAcc.Id;
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
        
        
    }*/
}