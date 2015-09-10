global class EskerUIController {
    public loan__Search__c searchObj{get;set;}
    public Blob fileContent{get;set;}
    public String fileName { get; set;}
    public String contactId {get; set;}
    
    public Contact con{get;set;}
    public boolean showLookup{get;set;}
    
    private Id loanAccountID;
    private loan__Loan_Account__c lA;
    private Date systemDate;
    
    public EskerUIController(ApexPages.StandardController controller) {
    
        searchObj = new loan__Search__c();
        con = (Contact) controller.getRecord();
        showLookup = (con.Id == null) ? true : false;
        
        systemDate = (new loan.GlobalLoanUtilFacade()).getCurrentSystemDate();
        
        if(!showLookup) {
            contactId = con.Id;
            con = getContact(con.Id);
        }
        
        loanAccountID = ApexPages.currentPage().getParameters().get('loanAccountId');
    }
    
    private Contact getContact(Id conId){
        Contact con = [Select Id,Name,
                          MailingStreet,
                          MailingCity,
                          MailingCountry,
                          MailingState,
                          MailingPostalCode,
                          Contact_ID__c,
                          Email
                   From Contact
                   Where Id =: conID];
        return con;
    }
    
    private loan__Fee__c getEskerFee(Id loanID) {
        loan__Fee__c retVal;
        
        //Get loan Fee set.
        lA = [Select Id,Name,
                   loan__Fee_Set__c,
                   loan__Principal_Remaining__c,
                   loan__Pay_off_Amount_As_Of_today__c
             from loan__Loan_Account__c
             Where Id =: loanId];
        
        //Get Esker Fee.                             
        if(lA.loan__Fee_Set__c != null) {
            List<loan__Fee_Junction__c> feeJunction = [Select Id,Name,
                                                          loan__fee__r.Id,
                                                          loan__fee__r.Name,
                                                          loan__fee__r.loan__Minimum_Amount__c,
                                                          loan__fee__r.loan__Maximum_Amount__c,
                                                          loan__fee__r.loan__amount__c,
                                                          loan__fee__r.loan__Fee_Calculation_Method__c,
                                                          loan__fee_Set__c
                                                        From loan__Fee_Junction__c
                                                        Where loan__fee_set__c =: la.loan__fee_Set__c
                                                        and loan__Fee__r.loan__Time_Of_Charge__c = 'Esker']; 
                                                            
            if(!feeJunction.isEmpty()){
                retVal = feeJunction[0].loan__Fee__r;
            }
        }
        
        return retVal;
    }
    
    global PageReference uploadMisc() {
        if(contactId == null
            && searchObj.Contact__c != null){
            con = getContact(searchObj.Contact__c);
  
        }
        
        if(String.isEmpty(con.MailingStreet)
            || String.isEmpty(con.MailingCity)
            || String.isEmpty(con.MailingCountry)
            || String.isEmpty(con.MailingPostalCode)
            || String.isEmpty(con.MailingState)) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Mailing address for this customer seems incorrect. Please check Mailing address information for customer.'));
            return null;
        }
        
        try{
            WSSnailMail sendMailWs;
            String result;
            
            if(!Test.isRunningTest()){
                sendMailWs = new WSSnailMail();
                result = sendMailWs.sendMail(fileContent, con,fileName);
            }
            
            //Apply Charge on Contract
            loan__Charge__c charge;
            if(loanAccountId != null) {
                //Get Esker Fee
                loan__Fee__c eskerFee = getEskerFee(loanAccountId);
                if(eskerFee != null) {
                
                    charge = new loan__Charge__c();
                    charge.loan__Loan_Account__c = loanAccountId;
                    charge.loan__Fee__c = eskerFee.Id;
                    charge.loan__Original_Amount__c = loan.FeeUtil.computeFee(eskerFee,lA);
                    charge.loan__Interest_Rate__c  = 0;
                    charge.loan__Date__c = systemDate;
                    insert charge;            
                }
            }    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, result));
            
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() + ' From line '+e.getLinenumber()));
             return null;
        }
        
        return new PageReference('/'+getNavigationId());
        
    }
    
    private Id getNavigationId(){
        if(loanAccountId != null){
            return loanAccountId;
        }else{
            return con.Id;
        }
    }
}