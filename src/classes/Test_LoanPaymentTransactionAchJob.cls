@isTest
public class Test_LoanPaymentTransactionAchJob{
  
  public static String CRON_EXP = '0 0 0 15 3 ? 2022';

     private testMethod  static void createSeedData() {
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
        
        Contact dummyClient = new Contact(LastName = 'Test Contact');
        insert dummyClient;
        
      
        loan__Client__c  objLoanClient  =    loan.TestHelper.createClient(dummyOffice); 
        loan__Loan_Account__c objLoanAccount =    loan.TestHelper.createLoanAccountForContactObj(
        dummyLP, dummyClient ,dummyFeeSet, dummyLoanPurpose,dummyOffice);
        objLoanAccount.loan__Loan_Status__c  = loan.LoanConstants.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        update objLoanAccount ;
        
        loan__Loan_account_Due_Details__c  objLoanAccountDetails = loan.TestHelper.createUnpaidDue(objLoanAccount ,5000);
        objLoanAccountDetails.loan__DD_Primary_Flag__c  = true;
        objLoanAccountDetails.loan__Payment_Satisfied__c = false;
        objLoanAccountDetails.loan__Due_Type__c = 1; 
        objLoanAccountDetails.Payment_Created__c = false;
        update objLoanAccountDetails ;
        test.startTest();
        LoanPaymentTransactionAchJob objLoanPayment =  new LoanPaymentTransactionAchJob();
        ID batchprocessid = Database.executeBatch(objLoanPayment);
        String jobId = System.schedule('TestLoanPaymentTransactionAchJob', CRON_EXP, new LoanPaymentTransactionAchJob ());                               
        test.stopTest();
      }
      
}