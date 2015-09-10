@RestResource(urlMapping='/v1/borrowerStatement')
global class WSBorrowerStatement {

    public class BankStatementRecord extends peer.CustomResponse{
        List<BankStatementTransaction> bRec;
        
        //List of Charges related to Loan Contract.
        List<ContractCharges> charges;
    
    }

    class BankStatementTransaction {
        //SFID of Loan Disbursal/ Loan Payment Transaction.
        String transactionId;
        
        //Transaction Type - 'Loan Disbursal' or 'Loan Repayment'.
        String transactionType;
        
        //Transaction Amount.
        Decimal transactionAmount;
        
        //Transaction Date
        Date transactionDate;
        
        //Transaction Timestamp.
        Datetime transactionDatetime;
        
        //LD - Disbursal Transaction Id & LP - Payment Transaction Id.
        String reference;
        
        //Loan Principal Outstanding. 
        String adjustedBalance;
        
        //This will be empty for Repayment Txns. - Only for Loan Disbursals
        String partnerID;
        
        //This will be empty for Repayment Txns. - Only For Loan Disbursals.
        String partnerUrl;
        
        
        public BankStatementTransaction(String transactionId,
                                  String transactionType,
                                  Decimal transactionAmount,
                                  Date transactionDate,
                                  Datetime transactionDatetime,
                                  String reference,
                                  String adjustedBalance,
                                  String partnerID,
                                  String partnerUrl) {
            this.transactionId = transactionId;
            this.transactionType = transactionType;
            this.transactionAmount = transactionAmount;
            this.transactionDateTime = transactionDateTime;
            this.transactionDate = transactionDate;
            this.reference = reference;
            this.adjustedBalance = adjustedBalance;
            this.partnerId = partnerId;
            this.partnerUrl = partnerUrl;
            
                                          
        }
    }
    
    class ContractCharges {
        
        Date chargeDate;
        Decimal originalChargeAmount;
        Decimal paidAmount;
        Decimal remainingChargeAmount;
        Decimal adjustedBalance;
    
    }
    
    @HttpGet 
    global static Response getLenderStatement() {
        //Business Logic.
        RestRequest req = RestContext.request;
        RestResponse restRes = RestContext.response;
        Response res = new Response();
        list<loan__Loan_Account__c> Contractlist ;
        List<BankStatementRecord> statementRecord = new List<BankStatementRecord>();
        RequestBodyParser.RequestBodyParams reqParams = RequestBodyParser.getJsonParamsFromRequest(req);
        if(reqParams == null) {
            
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Unable to parse request';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        Map<String, Object> params = reqParams.getParams();
        string ContractId;
        string borrowerId;
        Date  FromDate;
        Date Todate;
         try {
        if (params.get('borrowerId') != null) {
                borrowerId= (String)params.get('borrowerId');
            }
         if (params.get('ContractId') != null) {
                ContractId = (String)params.get('ContractId');
            }  
         if (params.get('FromDate') != null) {
                FromDate = (Date)params.get('FromDate');
            }  
         if (params.get('Todate') != null) {
                Todate = (Date)params.get('Todate');
            } 
         }catch(Exception e) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Unable to parse Request Params';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
         if(ContractId == null){
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            res.errorMessage = 'Contract Id Null';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;
        }
        
               
        res.response.add(statementRecord[0]);
        return res;
    }
    
}