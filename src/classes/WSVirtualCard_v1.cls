@RestResource(urlMapping='/v1/virtualCard')
global class WSVirtualCard_v1 {

    global class VirtualCardResponse extends Response {
         global VirtualCard card {get;set;}
           
         public VirtualCardResponse() {
             card = new VirtualCard();
         }
    }
    
    @HttpPost
    global static Response createVirtualCard() {
        RestRequest req = RestContext.request;
        RestResponse restRes = RestContext.response;
        VirtualCardResponse res = new VirtualCardResponse();
        
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
        String contractId = null;
        Decimal amount = null;
        Date systemDate;
        String merchantReference;
        String partnerId;
        Account partner;
        
        loan.GlobalLoanUtilFacade f = new loan.GlobalLoanUtilFacade();
        systemDate = f.getCurrentSystemDate();
        
        try {
            if (params.get('contractId') != null) {
                contractId = (String)params.get('contractId');
            }
            if(params.get('amount') != null) {
                amount = (Decimal)params.get('amount');
            }
            
            if(params.get('partnerId') != null) {
                merchantReference = (String)params.get('partnerId');
            }
        }catch(Exception e) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Error while parsing request parameters.';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }

        if(contractId == null){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'ContractId can not be null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        } 
        
        if(amount == null) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Amount can not be null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        //Fetch Merchant
        List<Account> partners = [Select Id,Name,
                                         partner_Id__c,
                                         loan__Broker__c
                                  From Account
                                  Where Partner_Id__c =: merchantReference];
                                  
        if(!partners.isEmpty()){                          
            partnerId = partners[0].Id;  
            partner = partners[0];                        
        }
        
        //Fetch Contract
        List<loan__Loan_Account__c> locContracts = [Select Id,Name,
                                                           loan__Contact__c,
                                                           loan__Contact__r.Name,
                                                           loan__Contact__r.FirstName,
                                                           loan__Contact__r.LastName,
                                                           loan__Contact__r.Email,
                                                           loan__Loan_Amount__c,
                                                           loan__Credit_Limit__c,
                                                           loan__Borrower_ACH__c,
                                                           loan__Contractual_Interest_Rate__c,
                                                           loan__Expected_Disbursal_Date__c,
                                                           loan__Expected_Repayment_Start_Date__c,
                                                           loan__Number_of_Installments__c,
                                                           loan__Time_Counting_Method__c,
                                                           loan__Balloon_Payment__c,
                                                           loan__Frequency_of_Loan_Payment__c,
                                                           loan__Interest_Calculation_Method__c,
                                                           loan__First_Installment_Date__c,
                                                           loan__Second_Installment_Date__c,
                                                           loan__Next_Installment_Date__c,
                                                           Contract_Originated_From__c,
                                                           loan__Term_Cur__c
                                                    From loan__Loan_Account__c
                                                    Where Id =: contractId];
        
        if (locContracts.isEmpty()) {
            res.errorCode = 'CONTRACT_NOT_FOUND';
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'LOC Contract not found for given ID';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;

        } 
        
        //Create Virtual Card
        Virtual_Card__c vCard;
        loan_ix.VirtualCard newCard;
        loan__Payment_Mode__c pMode;
        loan__Loan_Disbursal_Transaction__c dTxn;
        
        try {
            
            //Get API instance
            loan_ix.CardAPI api = loan_ix.FactoryFacade.getAPI();
            
            //get Custom Setting Details    
            loan_ix__Ixaris_Logins__c lDetails = loan_ix__Ixaris_Logins__c.getOrgDefaults();  
            
            String accessToken = api.login(false);    
            
            String custName = locContracts[0].loan__Contact__r.FirstName + ' ' +
                              locContracts[0].loan__Contact__r.LastName + ' # ' +
                              System.now();
            
            System.debug(LoggingLevel.ERROR,' accessToken '+accessToken);
            System.debug(LoggingLevel.ERROR,' accessToken '+custName);
            System.debug(LoggingLevel.ERROR,' accessToken '+lDetails.loan_ix__Currency__c);
            System.debug(LoggingLevel.ERROR,' accessToken '+amount+' '+lDetails.loan_ix__Card_Factory__c);
                                       
                                       
            //Create Virtual Card 
            newCard = api.issueVirtualCard(accessToken,custName,lDetails.loan_ix__Currency__c,
                                                               lDetails.Funding_Account_Reference__C,
                                                               amount,
                                                               lDetails.loan_ix__Card_Factory__c,'');
                                                                                        
            
            if(newCard == null){
                throw new GeneralException('Error while creating Virtual Card');
            }
            
            newCard = api.getVirtualCardDetails(accessToken,newCard.cardReference);
             
            //Loan Disbursement.
            BorrowerImpl b = new BorrowerImpl();
            dTxn = b.disburseLocAccount(systemDate,amount,
                                        locContracts[0],partnerId,
                                        lDetails.Funding_Account_Reference__C);
            
            dTxn = [Select Id,Disbursal_Transaction_Id__c,
                           Partner__c,
                           loan__Loan_Account__c
                    from loan__Loan_Disbursal_Transaction__c Where Id =: dTxn.Id];
            
            //Create Virtual Card Record.
            vCard = new Virtual_Card__c();
            vCard.Name = newCard.cardName;
            vCard.Loan_Account__c = locContracts[0].Id;
            vCard.Card_Reference__c = newCard.cardReference;
            vCard.Partner__c = partnerId;
            vCard.Loan_Disbursal_Transaction__c = dTxn.Id;
            insert vCard;
            
            //Setup Brokerage
            if(locContracts[0].Contract_Originated_From__c.equalsIgnoreCase('Organic Acquisition')) {
                List<loan__Commission_Plan__c> bPlan = b.getCommissionPlans();
                loan__Broker__c newBroker = b.setupBrokeragePlan(locContracts[0],partner,bPlan[0]);
            }
            
            //Setup Recurring ACH.
            pMode = [Select Id,Name from loan__Payment_Mode__c Where Name = 'ACH'];
            
            if(!isAchAlreadySetup(locContracts[0])) {
                b.setUpACHonContract(locContracts[0],date.today(),'Monthly','Recurring',pMode);
            }
            
        } catch(Exception e) {
            res.errorCode = peer.Constants.API_EXCEPTION;
            res.errorMessage = e.getMessage()+' From line '+e.getLineNumber();
            res.status = peer.Constants.ERROR;
            restRes.statuscode = peer.Constants.HTTP_INTERNAL_ERROR;
            return res;  
        }
                             
        res.content.add(dTxn);
        res.card = getVirtualCardforResponse(newCard);
        res.status = peer.Constants.SUCCESS;
        restRes.statuscode = peer.Constants.HTTP_OK;
        return res;
    }
    
    private static boolean isAchAlreadySetup(loan__Loan_Account__c loanAcc) {
        
        List<loan__Automated_Payment_setup__c> achSetup = [Select Id,Name from loan__Automated_Payment_Setup__c 
                                                           Where loan__Active__c = true 
                                                           and loan__CL_Contract__c =: loanAcc.Id];
    
        if(achSetup.isEmpty()){
            return false;
        }else{
            return true;
        }
    }
    
    private static VirtualCard getVirtualCardforResponse(loan_ix.VirtualCard card) {
        VirtualCard retVal = new VirtualCard();
        
        retVal.cardName = card.cardName;
        retVal.state = card.state;
        retVal.cardBrand = card.cardBrand;
        retVal.cardNumber = card.cardNumber;
        retVal.cardholderName = card.cardholderName;
        retVal.availableBalance = card.availableBalance;
        retVal.actualBalance = card.actualBalance;
        retVal.cvv = card.cvv;
        retVal.expiryDateMonth = card.expiryDateMonth;
        retVal.expiryDateYear = card.expiryDateYear;
        retVal.expiryPeriod = card.expiryPeriod;
        retVal.nameOnCard = card.nameOnCard;
        retVal.startDateMonth = card.startDateMonth;
        retVal.startDateYear = card.startDateYear;
        retVal.isDefault = card.isDefault;
        retVal.cardReference = card.cardReference;
        retVal.cardType = card.cardType;
        retVal.externalIdentifier = card.externalIdentifier;
        retVal.cardInfo = card.cardInfo;
        retVal.orderedCardInfo = card.orderedCardInfo;
        retVal.transactionReference = card.transactionReference;
        
        return retVal;
    }
}