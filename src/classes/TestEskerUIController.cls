@isTest 
public class TestEskerUIController {

    private static Contact c;
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
        dummyFee.loan__Time_OF_Charge__c = 'Esker';
        update dummyFee;
                                           
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
        
        c = new Contact(LastName = 'Test');
        c.MailingCity = 'RYE';
        c.MailingStreet = '22 Tower Street';
        c.MailingState = 'East Sussex';
        c.MailingCountry = 'GB';
        c.MailingPostalCode = 'TN31 7AT';
        insert c;
        
        //Create a dummy Loan Account
        loanAccount = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                    c,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        
    }
    
    public static testMethod void runPositiveTesT(){
        
        c = [Select Id,Name from Contact limit 1];
    
        Test.startTest();
            
            EskerUIController con = new EskerUIController(new ApexPages.StandardController(c));
            con.uploadMisc();
        
        Test.stopTest();
    
    }
    
    public static testMethod void runPositiveTesT1(){
        
        loanAccount = [Select Id,Name from loan__Loan_Account__C limit 1];
        c = [Select Id,Name from Contact limit 1];
        
        PageReference pageRef = Page.esker_UI;//Observe how we set the Page here
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('loanAccountId', loanAccount.Id);

    
        Test.startTest();
            
            EskerUIController con = new EskerUIController(new ApexPages.StandardController(c));
            con.searchObj.Contact__c = c.Id;
            con.uploadMisc();
        
        Test.stopTest();
    
    }
    
    public static testMethod void runNegativeTesT1(){
        
        loanAccount = [Select Id,Name from loan__Loan_Account__C limit 1];
        c = [Select Id,Name from Contact limit 1];
        c.MailingStreet = '';
        
        update c;
        
        PageReference pageRef = Page.esker_UI;//Observe how we set the Page here
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('loanAccountId', loanAccount.Id);

    
        Test.startTest();
            
            EskerUIController con = new EskerUIController(new ApexPages.StandardController(c));
            con.searchObj.Contact__c = c.Id;
            con.uploadMisc();
        
        Test.stopTest();
    
    }
}