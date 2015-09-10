public class RefundStatementHandler {
    private List<RefundFileWrapper> txnsToProcess;
    private Map<String,Id> cardtoloanMap;
    private Map<Id,List<Virtual_Card_Payment__c>> loanToRefundTxnsMap;
    private List<Virtual_Card_Payment__c> refundTxnsToCreate;
    private Map<String,RefundFileWrapper> cardReftoWrapperObjMap;
    
    private loan__Payment_Mode__c pMode;
    private Date sysDate;
    private loan.GlobalLoanUtilFacade facade;
    
    private List<loan__Loan_Payment_Transaction__c> loanPaymentsToCreate;
    
    public RefundStatementHandler(List<RefundFileWrapper> txnsToProcess) {
        this.txnsToProcess = txnsToProcess;
        
        cardtoloanMap = new Map<String,Id>();
        loanToRefundTxnsMap = new Map<Id,List<Virtual_Card_Payment__c>>();
        refundTxnsToCreate = new List<Virtual_Card_Payment__c>();
        cardReftoWrapperObjMap = new Map<String,RefundFileWrapper>();
        
        loanPaymentsToCreate = new List<loan__Loan_Payment_Transaction__c>();
        
        pMode = [Select Id,Name from loan__Payment_Mode__C Where Name = 'Refund'];
        
        facade = new loan.GlobalLoanUtilFacade();
        sysDate = facade.getCurrentSystemDate();
        
    }
    
    public void handleStatement() {
    
        Set<String> cardReferences = new Set<String>();
        
        for(RefundFileWrapper rec : txnsToProcess) { 
            cardReftoWrapperObjMap.put(rec.strDestinationDetails,rec);
        }
        
        cardReferences = cardReftoWrapperObjMap.keyset();
        
        List<Virtual_Card__c> virtualCards = [Select Id,Name,
                                                     Loan_Account__c,
                                                     Card_Reference__c
                                              From Virtual_Card__c
                                              Where Card_Reference__c in: cardReferences
                                              and Card_Reference__c != null];
        
        System.debug(LoggingLevel.ERROR,' Virtual CArds found '+virtualCards.size());
        
        //Prepare map to get Loan ID for particular Card Reference.                                     
        if(!virtualCards.isEmpty()) {
            for(Virtual_CArd__c vCard : virtualCards) {
                cardtoloanMap.put(vCard.Card_Reference__c,vCard.Loan_account__c);
            }
            
            //Create Refund Transactions
            List<Virtual_Card_Payment__c> paymentList;
            Virtual_Card_Payment__c tempTxn;
            
            for(Virtual_CArd__c vCard : virtualCards) {
                
                //check if there are any txns for given loan.
                paymentList = loanToRefundTxnsMap.get(vCard.Loan_Account__c);
                
                if(paymentList == null ) {
                    //There is no payment already created for this loan
                    paymentList = new List<Virtual_Card_Payment__c>();
                    
                    //Create new virtual card refund txn.
                    tempTxn = getRefundPayment(vCard,cardReftoWrapperObjMap.get(vCard.Card_Reference__c));
                    
                    //Add to list
                    paymentList.add(tempTxn);
                    
                    //Add list to map for future iterations on list 45.
                    loanToRefundTxnsMap.put(vCard.Loan_Account__c,paymentList);
                    
                }else if(!paymentList.isEmpty()){
                    //There is/are payemnts on loan for other card references. Merge all later.
                    //Create new virtual card refund txn.
                    tempTxn = getRefundPayment(vCard,cardReftoWrapperObjMap.get(vCard.Card_Reference__c));
                    
                    //Add to list
                    paymentList.add(tempTxn);
                    
                    //Add list to map for future iterations on list 45.
                    loanToRefundTxnsMap.put(vCard.Loan_Account__c,paymentList);
                }
                
            }
            
            //Get consolidate Loan Payment for all virtual payments on same loan.
            for(Id loanId : loanToRefundTxnsMap.keyset()) {
                System.debug(LoggingLevel.ERROR,' In consolidate Payment for loop ');
                paymentList = loanToRefundTxnsMap.get(loanId);
                System.debug(LoggingLevel.ERROR,' Payment List for '+loanId+' '+paymentList.size());
                
                if(paymentList != null) {
                   refundTxnsToCreate.addAll(paymentList);
                   loanPaymentsToCreate.add(getConsolidatedLoanPayment(loanId,sysDate,paymentList));
                }else {
                    //no payments to create for given loan.
                }
            }
            
            //Insert loan payments.
            Savepoint sp = Database.setSavePoint();
            try {
                insert loanPaymentsToCreate;
                
                for(loan__Loan_Payment_Transaction__C lpt : loanPaymentsToCreate) {
                    lpt.loan__Cleared__c = true;
                }
                
                update loanPaymentsToCreate;
                
                insert refundTxnsToCreate;
            }catch(Exception e){
                Database.rollback(sp);
                throw e;
            }
            
            //Update Loan Payment Reference on Virtual Payments.
            refundTxnsToCreate = new List<Virtual_Card_Payment__c>();
            for(loan__Loan_Payment_Transaction__c lpt : loanPaymentsToCreate) {
                paymentList = loanToRefundTxnsMap.get(lpt.loan__Loan_Account__c);
                
                if(paymentList != null) {
                    
                    for(Virtual_Card_Payment__c vPayment : paymentList) {
                        vPayment.Loan_Payment_Transaction__c = lpt.Id;
                    }
                    refundTxnsToCreate.addAll(paymentList);
                }
            }
            
            //update Virtual CArd payments with LPT reference.
            try {
                update refundTxnsToCreate;
            }catch(Exception e){
                Database.rollback(sp);
                throw e;
            }
            
        }else {
            //No virtual cards found in system. goes to exception report.
            throw new GeneralException('No Virtual Cards found for received references');
        }
        
    }
    
    private loan__Loan_Payment_Transaction__c getConsolidatedLoanPayment(Id loanId, Date txnDate,
                                                                         List<Virtual_Card_Payment__c> pList) {
        loan__Loan_Payment_Transaction__c retVal;
        
        //calculate total amount
        Decimal txnAmount = 0;
        for(Virtual_Card_Payment__c vPayment : pList){
            txnAmount += vPayment.Transaction_Amount__c;
        }
        
        //Create Loan Payment.
        retVal = new loan__Loan_Payment_Transaction__c();
        retVal.loan__Loan_Account__c = loanId;
        retVal.loan__transaction_amount__c = txnAmount;
        retVal.loan__Payment_Mode__c = pMode.Id;
        retVal.loan__Transaction_date__c = txnDate;
        retVal.loan__Payment_Application_Mode__c = 'Current Dues';
        
        return retVal;
    }
    
    private Virtual_Card_Payment__c getRefundPayment(Virtual_CArd__c vCard, RefundFileWrapper txnRec) {
        Virtual_Card_Payment__c retVal = new Virtual_Card_Payment__c();
        
        retVal.Transaction_Amount__c = Decimal.valueOf(txnRec.strTransactionAmount);
        
        Datetime dt = Datetime.parse(txnRec.strTrasactionDate);
        retVal.Transaction_Date__c = dt.date();
        
        retVal.Virtual_Card__c = vCard.Id;
        retVal.Transaction_Type__c = 'REFUND';
        
        return retVal;
    }
}