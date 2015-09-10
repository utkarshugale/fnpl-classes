@RestResource(urlMapping='/v1/lineofcredit')
global class WSLocAccounts_v1 {
    
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
        Boolean ach = false;
        Boolean isProductB = false;
        
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
            if(params.get('interestRate') != null) {
                interestRate = (Decimal)params.get('interestRate');
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
        system.debug('*******borrowerId ****'+borrowerId );
        // Check if borrowerId is valid
        String fieldName = loan__API_Configuration__c.getOrgDefaults().loan__Account_Id_Field__c;
        if (fieldName == null) {
            fieldName = peer.Constants.DEFAULT_ID;
        } 
       
        System.debug(LoggingLevel.ERROR,' Contact Id '+borrowerId);
        //Make this dynamic query
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
        If(!isProductB){
            loan.GlobalLoanUtilFacade f = new loan.GlobalLoanUtilFacade();
            disbursalDate = f.getCurrentSystemDate();
            firstInstallmentDate = disbursalDate.addDays(30);
        }else{
        
        }
        
        loan__Loan_Account__c lA = null;
        Virtual_Card__c vCard;
        try {
            BorrowerImpl b = new BorrowerImpl();
            lA = b.createLocAccount(Id.valueOf(borrowerId),lp.Id, loanAmount, term, interestRate, 'Holiday', 
                                        disbursalDate,
                                        firstInstallmentDate, 'Monthly',0, 
                                        0,ach, bankId);
            
            //Get API instance
            loan_ix.CardAPI api = loan_ix.FactoryFacade.getAPI();
            
            //get Custom Setting Details    
            loan_ix__Ixaris_Logins__c lDetails = loan_ix__Ixaris_Logins__c.getOrgDefaults();  
            
            String accessToken = api.login(false);    
            
            String custName = acc[0].FirstName + ' ' +acc[0].LastName;
                                       
            //Create Virtual Card 
            loan_ix.VirtualCard newCard = api.issueVirtualCard(accessToken,custName,lDetails.loan_ix__Currency__c,
                                                               '0RABcMDSlcePtQKBnP4GuXs5x',
                                                               loanAmount,lDetails.loan_ix__Card_Factory__c,'');
                                                                                         
            System.debug(LoggingLevel.ERROR,'New Card '+newCard);
            
            if(newCard == null){
                throw new GeneralException('Error while creating Virtual Card');
            }
            
            //performDmls.
            Id rt = [SELECT ID, Name 
                     FROM RecordType 
                     WHERE DeveloperName = 'Line_Of_Credit_Record_Type' 
                     AND sObjectType = 'loan__Loan_Account__c'].Id;
            
            insert lA;
            
            //Create Virtual Card Record.
            vCard = new Virtual_Card__c();
            vCard.Loan_Account__c = lA.Id;
            vCard.Card_Reference__c = newCard.cardReference;
            
            insert vCard;
              
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

}