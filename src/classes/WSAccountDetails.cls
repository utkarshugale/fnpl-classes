@RestResource(urlMapping='/v1/accountDetails')
global with sharing class WSAccountDetails {
    
    @HttpPost
    global static Response getAccountDetails() {
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
        String username = null;
        
        loan.GlobalLoanUtilFacade f = new loan.GlobalLoanUtilFacade();
        Date systemDate = f.getCurrentSystemDate();
        
        try {
            if (params.get('username') != null) {
                username = (String)params.get('username');
            }
        }catch(Exception e) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Error while parsing request parameters.';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }

        if(username == null){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Username can not be null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        } 
        
        //Fetch Contact.
        List<Contact> bList = [Select Id,Name from Contact Where Id =: username];
        
        if(bList.isEmpty()){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'No user found for given username';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
        if(bList.size() > 1){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'More than one users found for given username. Please contact support.';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
                
        Contact borrower = bList[0];
        
        Set<String> notAllowedStatus = new Set<String>();
        notAllowedStatus.add(loan.LoanConstants.LOAN_STATUS_PARTIAL_APPLICATION);
        notAllowedStatus.add(loan.LoanConstants.LOAN_STATUS_PENDING_APPROVAL);
        notAllowedStatus.add(loan.LoanConstants.LOAN_STATUS_CLOSED_OBLIGATIONS_MET);
        
        //Fetch Contract
        List<loan__Loan_Account__c> locContracts = [Select Id,Name,
                                                           loan__Contact__c,
                                                           loan__Contact__r.Name,
                                                           loan__Contact__r.Email,
                                                           loan__Credit_Limit__c,
                                                           Fraudulent__c,
                                                           loan__Total_Amount_Remaining__c,
                                                           loan__Pay_Off_Amount_As_Of_Today__c,
                                                           loan__Borrower_ACH__c,
                                                           loan__Principal_Remaining__c,
                                                           loan__Minimum_Due_Amount_On_Billing__c,
                                                           loan__Next_Installment_Date__c,
                                                           Available_Credit__c,
                                                           //Loan Payment Transactions.
                                                           (Select Id,Name,
                                                                   loan__Transaction_Amount__c,
                                                                   loan__Transaction_Date__c,
                                                                   loan__Payment_Mode__C,
                                                                   loan__Cleared__c
                                                            From loan__Loan_Payment_Transactions__r
                                                            Order by loan__Transaction_time__c DESC),
                                                            //Loan Disbursement Transactions.
                                                            (Select Id,Name,
                                                                    loan__Disbursed_Amt__c,
                                                                    loan__Disbursal_Date__c,
                                                                    loan__Reference__c,
                                                                    Partner__r.Partner_Id__c
                                                             From loan__Loan_Disbursal_Transactions__r
                                                             Order by loan__Disbursal_Date__c DESC)
                                                    From loan__Loan_Account__c
                                                    Where loan__Contact__c =: borrower.Id
                                                    and loan__Contact__c != null
                                                    and loan__Loan_Status__c NOT IN: notAllowedStatus];
        
        if (locContracts.isEmpty()) {
            res.errorCode = 'CONTRACT_NOT_FOUND';
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'LOC Contract not found for given Username';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;

        } 
                
        try {
            for(loan__Loan_Account__c loan : locContracts){
                res.content.add(loan);
            }
        } catch(Exception e) {
            
            res.errorCode = peer.Constants.API_EXCEPTION;
            res.errorMessage = e.getMessage()+' From line '+e.getLineNumber();
            res.status = peer.Constants.ERROR;
            restRes.statuscode = peer.Constants.HTTP_INTERNAL_ERROR;
            return res;  
        }
                             
        //res.content.add(vCard);
        res.status = peer.Constants.SUCCESS;
        restRes.statuscode = peer.Constants.HTTP_OK;
        return res;
    }
    
}