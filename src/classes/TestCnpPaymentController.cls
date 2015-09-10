@isTest
public class TestCnpPaymentController {

    private static loan__Loan_Account__c loanAccount;
    private static Date systemDate;
    
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
        loanAccount = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
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
        pMode.Name = 'CNP';
        insert pMode;
        
        
        systemDate = new loan.GlobalLoanUtilFacade().getcurrentSystemDate();
        
    }
    
    public static tesTMethod void runPositiveTest() {
    
        loan__Loan_Payment_Transaction__c payment = new loan__Loan_Payment_Transaction__c();
        loanAccount = [Select Id,Name from loan__Loan_Account__c limit 1];
        
        payment.loan__Loan_Account__c = loanAccount.Id;
        payment.loan__Transaction_Date__c = systemDate;
        payment.loan__Transaction_amount__c = 100;
        payment.loan__Payment_Mode__c = [Select Id,Name from loan__Payment_Mode__c where Name = 'CNP'].Id;
        
        Test.StartTest();
        
            CnpLoanPaymentController con = new CnpLoanPaymentController(new ApexPages.StandardController(payment));
            con.CnpBank.Bank_Card_Details__c = '4444333322221111';
            con.cnpBAnk.Expiry_Month__c = 01;
            con.cnpBank.Expiry_Year__c = 21;
            con.cnpBank.CVV__c = '774';
            
            con.save();
            con.setManualPaymentMode();
            con.doValidate();
        
        Test.StopTest();
    }
    
}