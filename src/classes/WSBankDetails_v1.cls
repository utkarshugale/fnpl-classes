@RestResource(urlMapping='/v1/bankDetails')
global class WSBankDetails_v1 {

    @HttpPost
    global static Response createBankAccount() {
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
        String contractId = null;
        String cardNumber = null;
        String cvv = null;
        Integer month = null;
        Integer year = null;
        String bankName = null;
        Date systemDate;
        
        loan.GlobalLoanUtilFacade f = new loan.GlobalLoanUtilFacade();
        systemDate = f.getCurrentSystemDate();
        
        try {
            if (params.get('contractId') != null) {
                contractId = (String)params.get('contractId');
            }
            if(params.get('cardNumber') != null) {
                cardNumber = (String)params.get('cardNumber');
            }
            if(params.get('cvv') != null) {
                cvv = (String)params.get('cvv');
            }
            if(params.get('month') != null) {
                month = (Integer)params.get('month');
            }
            if(params.get('year') != null) {
                year = (Integer)params.get('year');
            }
            if(params.get('bankName') != null){
                bankName = (String)params.get('bankName');
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
        
        if(cardNumber == null) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Card Number can not be null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        if(cvv == null) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Cvv can not be null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        if(month == null) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Month can not be null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        if(year == null) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Year can not be null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        //Fetch LOC
        List<loan__Loan_Account__c> locContracts = [Select Id,Name,
                                                           loan__Contact__c,
                                                           loan__Contact__r.Name,
                                                           loan__Contact__r.FirstName,
                                                           loan__Contact__r.LastName,
                                                           loan__Loan_Amount__c,
                                                           loan__Credit_Limit__c,
                                                           loan__Borrower_ACH__c
                                                    From loan__Loan_Account__c
                                                    Where Id =: contractId];
        
        if (locContracts.isEmpty()) {
            res.errorCode = 'CONTRACT_NOT_FOUND';
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'LOC Contract not found for given ID';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;

        } 
                                                    
        loan__Loan_Account__c locRec = locContracts[0];  
        loan__Bank_Account__c bankAcc;
        loan__bank_Account__c oldBank;
        
        try{
            //If bank Account already exists, Disable old one & create new rec.
            if(locRec.loan__Borrower_ACH__c != null){
                oldBank = [Select Id,Name,
                                  loan__Active__c,
                                  Bank_Card_Details__c,
                                  Expiry_Month__c,
                                  Expiry_year__c
                           From loan__Bank_Account__c Where Id =: locRec.loan__Borrower_ACH__c];
                oldBank.loan__Active__c = false;
                update oldBank;
            }
            
            //Create New
            bankAcc = new loan__Bank_Account__c();
            bankAcc.loan__Contact__c = locRec.loan__Contact__c;
            bankAcc.Bank_Card_Details__c = cardNumber;
            bankAcc.Cvv__c = cvv;
            bankAcc.expiry_Month__c = month;
            bankAcc.Expiry_year__c = year;
            bankAcc.loan__Account_Usage__c = 'Borrower/Investor Account';
            bankAcc.loan__Active__c = true;
            bankAcc.loan__Account_Type__c = 'Savings';
            bankAcc.loan__Bank_Account_Number__c = cardNumber;
            bankAcc.loan__Bank_Name__c = (bankName != null) ? bankName :'Visa';
            
            insert bankAcc;
            
            locRec.loan__Borrower_ACH__c = bankAcc.Id;
            update locRec;
                                                              
        }Catch(Exception e){
            System.debug(LoggingLevel.ERROR,' Error : Bank Details '+e.getMessage()+' from line '+e.getLineNumber());
            res.errorCode = peer.Constants.API_EXCEPTION;
            res.errorMessage = e.getMessage()+' From line '+e.getLineNumber();
            res.status = peer.Constants.ERROR;
            restRes.statuscode = peer.Constants.HTTP_INTERNAL_ERROR;
            return res;  
        }
        
        res.content.add(bankAcc);
        if(oldBank != null) {
            res.content.add(oldBank);
        }
        res.status = peer.Constants.SUCCESS;
        restRes.statuscode = peer.Constants.HTTP_OK;
        return res;
    }
}