@isTest
public class TestUtilSB {
	
	public static void createSeedData() {
        loan.TestHelper.createSeedDataForTesting();
        
        loan__Currency__c curr                    = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount          = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount       = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee                     = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount);                                    
        loan__Fee_Set__c dummyFeeSet           	  = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction 	  = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        
        loan__Office_Name__c dummyOffice          = loan.TestHelper.createOffice();
        
        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP             = loan.TestHelper.createLoanProduct(dummyOffice,
                                                                                   dummyAccount, 
                            													   curr, 
                            													   dummyFeeSet);
        dummyLP.loan__Payment_Application_Mode__c = loan.LoanConstants.LOAN_PAYMENT_APPLICATION_CURRENT_DUES;
        
        update dummyLP;
        //System.debug(LoggingLevel.ERROR,'LoanProduct in test: ' + dummyLP.Disable_Reserve_Amount_for_Next_Due__c);
        loan__Loan_Purpose__c dummyLoanPurpose     = loan.TestHelper.createLoanPurpose();        
        
        Contact dummyClient = new Contact(LastName = 'Test Contact');
        insert dummyClient;
        
        loan__Bank_Account__c loanAcc = new loan__Bank_Account__c();
        loanAcc.Bank_Card_Details__c    =   'XXXX-XXXX-XXXX-0203' ;
        loanAcc.CVV__c  =   'XXX' ;
        loanAcc.Expiry_Month__c =   9   ;
        loanAcc.Expiry_Year__c  =   17  ;
        loanAcc.loan__Account_Type__c   =   'Savings' ;
        loanAcc.loan__Account_Usage__c  =   'Borrower/Investor Account'   ;
        loanAcc.loan__Active__c =   TRUE   ;
        loanAcc.loan__Bank_Account_Number__c    =   'XXXXXXXXXXXX0203'    ;
        loanAcc.loan__Bank_Name__c  =   'Visa'    ;
        loanAcc.loan__Contact__c    =   dummyClient.Id  ;
        loanAcc.peer__Allow_for_Direct_Credit__c    =   FALSE   ;
        loanAcc.peer__Savings_No__c =   FALSE   ;
        loanAcc.peer__Savings_Other__c  =   FALSE   ;
        loanAcc.peer__Savings_Pensions__c   =   FALSE   ;
        insert loanAcc;
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
}
}