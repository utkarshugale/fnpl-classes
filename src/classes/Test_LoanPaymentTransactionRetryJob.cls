@istest(SeeAllData=false)
public class Test_LoanPaymentTransactionRetryJob{
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
        
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
       /* loan__Loan_Account__c loanAcc = [SELECT Id, Name,Loan_Amount__c, Interest_Remaining__c, Fees_Remaining__c,
                                        Reserve_Amount_for_Next_Due__c,Payment_Application_Mode__c , Principal_Remaining__c 
                                    FROM Loan_Account__c  
                                    WHERE Id=:loanAccount.ID];*/
    }
    
    
  
  static testMethod void loanPaymentTransationTest() {
      createSeedData();
      Payment_Retry__c objPaymentRetry =  new Payment_Retry__c();
      objPaymentRetry.Name = 'TestPaymentRetry';
      objPaymentRetry.Transaction_Date__c = date.today();
      objPaymentRetry.Debit_Amount__c = 10000;
     // objPaymentRetry.CL_Contract__c = objLoanAccount.id;
      insert objPaymentRetry;
      test.startTest();
      LoanPaymentTransactionRetryJob  objPayment = new LoanPaymentTransactionRetryJob ();
      ID batchprocessid = Database.executeBatch(objPayment );
       String jobId = System.schedule('TestLineOfCreditExpiryJob',

                        CRON_EXP,

                        new LoanPaymentTransactionRetryJob());
      //objPayment .getNewLoanPayment(objPaymentRetry);
      test.stopTest();
  }
}