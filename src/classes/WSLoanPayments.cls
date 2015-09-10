@RestResource(urlMapping='/v1/payments')
global with sharing class WSLoanPayments {

    @HTTPPOST
    global static Response createLoanPayment(){
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
        Decimal amount = null;
        Date txnDate = null;
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
            if(params.get('amount') != null){
                amount = (Decimal)params.get('amount');
            }
            if(params.get('transactionDate') != null){
                txnDate = (Date)params.get('transactionDate');
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
        
        //Payment Mode
        loan__Payment_Mode__c pMode = [Select Id,Name from loan__Payment_Mode__c Where Name = 'ACH'];
        
        //Create Payment on LOC
        loan__Loan_Payment_Transaction__c adHocLpt = new loan__Loan_Payment_Transaction__c();
        adHocLpt.loan__Transaction_amount__c = amount;
        adhocLpt.loan__Transaction_Date__c = (txnDate != null) ? txnDate : systemDate;
        adhocLpt.loan__Payment_Mode__c = pMode.Id;
        adhocLpt.loan__Loan_Account__c = locRec.Id;
        
        //Bank Account Packate.
        loan__Bank_Account__c card = new loan__Bank_Account__c();
        card.Bank_Card_Details__c = cardNumber;
        card.Expiry_Month__c = month;
        card.Expiry_Year__c = year;
        card.loan__Bank_Account_Number__c = cardNumber;
        
        
        //Send Payment to Datacash
        try{
            BorrowerImpl impl = new BorrowerImpl();
            String result = impl.sendPaymentToDataCash(endpoint,username,password,card,adhocLpt);
            
            if(result.equalsIgnoreCase('SUCCESS')){
                //requery created Payment.
                adhocLpt = [Select Id,Name,
                                   loan__Loan_Account__C,
                                   loan__Transaction_Amount__c,
                                   loan__Transaction_Date__c,
                                   loan__Payment_Mode__r.Name
                            From loan__Loan_Payment_Transaction__C
                            Where Id =: adhocLpt.Id];
                            
                res.content.add(adhocLpt);
                res.status = peer.Constants.SUCCESS;
                restRes.statuscode = peer.Constants.HTTP_OK;
                           
            }
        }catch(Exception e){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Error While Creating Payment : '+e.getMessage()+' from line '+e.getLinenumber();
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
        }
        return res;
    }
}