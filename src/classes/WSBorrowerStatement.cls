@RestResource(urlMapping='/v1/borrowerStatement')
global class WSBorrowerStatement {

    global class BankStatementRecord extends peer.CustomResponse{
        List<BankStatementTransaction> BankTxnRec;
        
        //List of Charges related to Loan Contract.
        List<ContractCharges> charges;
        BankStatementRecord(){
              BankTxnRec = new  List<BankStatementTransaction>();
               charges = new  List<ContractCharges>();
        }
    
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
        Decimal adjustedBalance;
        
        //This will be empty for Repayment Txns. - Only for Loan Disbursals
        String partnerID;
        
        //This will be empty for Repayment Txns. - Only For Loan Disbursals.
        String partnerUrl;
        public BankStatementTransaction(){}
        
        public BankStatementTransaction(String transactionId,
                                  String transactionType,
                                  Decimal transactionAmount,
                                  Date transactionDate,
                                  Datetime transactionDatetime,
                                  String reference,
                                  Decimal adjustedBalance,
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
        public ContractCharges(){}
        public ContractCharges(Date chargeDate,Decimal originalChargeAmount,Decimal paidAmount,
                               Decimal remainingChargeAmount,
                              Decimal adjustedBalance){
          
           this.chargeDate=chargeDate;
           this.originalChargeAmount=originalChargeAmount;
           this.paidAmount=paidAmount;
           this.remainingChargeAmount=remainingChargeAmount;
           this.adjustedBalance=adjustedBalance;                       
            
        }
    
    }
    
    @HttpPost 
    global static Response getLenderStatement() {
        //Business Logic.
        RestRequest req = RestContext.request;
        RestResponse restRes = RestContext.response;
        Response res = new Response();
        list<loan__Loan_Account__c> Contractlist ;
        BankStatementRecord statementRecord = new BankStatementRecord();
        RequestBodyParser.RequestBodyParams reqParams = RequestBodyParser.getJsonParamsFromRequest(req);
        system.debug('reqParams==='+reqParams);
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
                string dateval = (string)params.get('FromDate');
                FromDate = date.valueOf(dateval);
                
         }else{
             FromDate = Date.today().toStartOfMonth();
         }  
         if (params.get('Todate') != null) {
             string dateval =(string)params.get('Todate');
              Todate = date.valueOf(dateval);
             
         }else{
             Todate=date.today();
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
         Contractlist = new list<loan__Loan_Account__c>();
        
 loan__Loan_Account__c Contract =[SELECT id,Name,Expiry_Date__c,loan__Invalid_Data__c,
                        (select id,Name,loan__cleared__c,loan__Rejected__c,
                               loan__Reversed__c,
                               loan__Transaction_Amount__c,
                               loan__Transaction_Date__c,
                               loan__Sent_To_Ach__c,
                               loan__Sent_To_Ach_On__c,
                               loan__Payment_Mode__c,loan__Transaction_Time__c,loan__Balance__c 
                        From loan__Loan_Payment_Transactions__r Where loan__Transaction_Date__c >=: FromDate 
                         AND loan__Transaction_Date__c <=:Todate AND
                         loan__cleared__c=true AND loan__Reversed__c=false
                        AND loan__Rejected__c=false),
                        (Select Id,Name,
                         loan__Disbursed_Amt__c,
                         loan__Disbursal_Date__c,
                         loan__Reference__c,
                         Partner__r.Partner_Id__c,Partner__r.Website
                         From loan__Loan_Disbursal_Transactions__r Where loan__Disbursal_Date__c >=: FromDate 
                         ANd loan__Disbursal_Date__c <=:Todate AND
                         loan__cleared__c=true AND loan__Reversed__c=false
                        AND loan__Rejected__c=false),
                        (select id,Name,
                         loan__Original_Amount__c,loan__Interest_Rate__c,
                         loan__Total_Due_Amount__c,loan__Paid_Amount__c,
                        loan__Date__c,loan__Paid__c From loan__Charges__r where loan__Paid__c=false)
                        From loan__Loan_Account__c WHERE Id=:ContractId];
         if (Contract==null) {
            res.errorCode = 'CONTRACT_NOT_FOUND';
            res.status = peer.Constants.ERROR;
            res.errorMessage = ' Contract not found for given ID';
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            return res;

        } 
        statementRecord = createresponse(Contract);      
        res.response.add(statementRecord);
        return res;
    }
    global static BankStatementRecord createresponse(loan__Loan_Account__c Contract){
          BankStatementRecord  BankRecord = new BankStatementRecord();
        for(loan__Loan_Disbursal_Transaction__c lobj:Contract.loan__Loan_Disbursal_Transactions__r){
               BankStatementTransaction bankTxn = new BankStatementTransaction(lobj.id,'Loan Disbursal',
                                                                               lobj.loan__Disbursed_Amt__c,
                                                                               lobj.loan__Disbursal_Date__c,
                                                                               null,
                                                                               lobj.loan__Reference__c,
                                                                               null,
                                                                               lobj.Partner__r.Partner_Id__c,
                                                                               lobj.Partner__r.Website
                                                                               );
         
            BankRecord.BankTxnRec.add(bankTxn);
                
            }
        for(loan__Loan_Payment_Transaction__c lobj:Contract.loan__Loan_Payment_Transactions__r){
               BankStatementTransaction bankTxn = new BankStatementTransaction(lobj.id,'Loan Repayment',
                                                                               lobj.loan__Transaction_Amount__c,
                                                                               lobj.loan__Transaction_Date__c,
                                                                               lobj.loan__Transaction_Time__c,
                                                                               lobj.Name,
                                                                               lobj.loan__Balance__c,
                                                                               null,
                                                                               null
                                                                               );
            BankRecord.BankTxnRec.add(bankTxn);
            
            
                
            }
        for(loan__Charge__c LChobj:Contract.loan__Charges__r){
             ContractCharges  charge = new ContractCharges ( LChobj.loan__Date__c,
                                                             LChobj.loan__Original_Amount__c,
                                                             LChobj.loan__Paid_Amount__c,
                                                             LChobj.loan__Total_Due_Amount__c,
                                                             null
                                                              );
            BankRecord.charges.add(charge);
            
          }
        return BankRecord;
        }
        
    }