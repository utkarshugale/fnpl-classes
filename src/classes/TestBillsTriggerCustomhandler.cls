@isTest
public class TestBillsTriggerCustomhandler {
    private static loan__Loan_Account__c loanAccount;
    
    @testSetup static void createSeedData() {
        System.debug(LoggingLevel.eRROR,' running test data ');
        loan.TestHelper.createSeedDataForTesting();
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet);
        dummyLP.loan__Payment_Application_Mode__c = loan.LoanConstants.LOAN_PAYMENT_APPLICATION_CURRENT_DUES;
        
        update dummyLP;
        
        //System.debug(LoggingLevel.ERROR,'LoanProduct in test: ' + dummyLP.Disable_Reserve_Amount_for_Next_Due__c);
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();        
        
        Contact c = new Contact(LastName = 'Test');
        insert c;
        
        //Create a dummy Loan Account
        loanAccount = loan.TestHelper.createLocAccountForContactObj(dummyLP,
                                                    c,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        
        
        
        //Create Virtual Card.
        Virtual_Card__c vCard = new Virtual_Card__c();
        vCard.Loan_Account__c = loanAccount.Id;
        vCard.Card_Reference__c = '0RACI_D8GBZeiKne-aQDNwV52';
        
        insert vCard;
        
        loan__Payment_Mode__C pMode = new loan__Payment_Mode__C();
        pMode.Name = 'Refund';
        insert pMode;
        
        
        
    }
    
    public static testMethod void runNegativeTests() {
        RecordType rt = [Select Id,Name 
                                    From RecordType Where DeveloperName = 'Line_Of_Credit_Record_Type' 
                                    AND sObjectType = 'loan__Loan_Account__c'];
        System.debug(LoggingLevel.ERROR,' Record Type '+rt+' '+loanAccount);    
        
        loanAccount = [Select Id,Name,RecordTypeId,loan__Minimum_Due_Amount_On_Billing__c from loan__Loan_Account__c limit 1];                        
        loanAccount.RecordTypeId = rt.Id;
        loanAccount.loan__Minimum_Due_Amount_On_Billing__c = 10;
        update loanAccount;
        
        Test.startTest();
            loan__Loan_account_Due_Details__c due = new loan__Loan_account_Due_Details__c();
            due.loan__Loan_Account__c = loanAccount.Id;
            due.loan__Due_Amt__c = 50;
            due.loan__Due_Date__c = Date.today();
            
            insert due;
            
        Test.stopTest();
    
    }
    
    public static testMethod void runPositiveTests() {
        RecordType rt = [Select Id,Name 
                                    From RecordType Where DeveloperName = 'Line_Of_Credit_Record_Type' 
                                    AND sObjectType = 'loan__Loan_Account__c'];
        System.debug(LoggingLevel.ERROR,' Record Type '+rt+' '+loanAccount);    
        
        loanAccount = [Select Id,Name,RecordTypeId,loan__Minimum_Due_Amount_On_Billing__c from loan__Loan_Account__c limit 1];                        
        loanAccount.RecordTypeId = rt.Id;
        loanAccount.loan__Minimum_Due_Amount_On_Billing__c = 25;
        update loanAccount;
        
        Test.startTest();
            loan__Loan_account_Due_Details__c due = new loan__Loan_account_Due_Details__c();
            due.loan__Loan_Account__c = loanAccount.Id;
            due.loan__Due_Amt__c = 50;
            due.loan__Due_Date__c = Date.today();
            
            insert due;
            
        Test.stopTest();
    
    }

}