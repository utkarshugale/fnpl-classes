@isTest(seealldata=false)
public class Test_LineOfCreditExpiryJob{
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
                                                    
        loanAccount.Expiry_Date__c = date.today().addDays(-1);
        loanAccount.loan__Invalid_Data__c = false;
        loanAccount.Is_Expired__c = false;
        loanAccount.RecordTypeId = '012240000009IWXAA2';
        update loanAccount ;
        
        system.debug('****loanAccount***'+loanAccount);                  
        loan__Client__c  objLoanClient  =    loan.TestHelper.createClient(dummyOffice); 
        loan__Loan_Account__c objLoanAccount =    loan.TestHelper.createLoanAccountForContactObj(
        dummyLP, dummyClient ,dummyFeeSet, dummyLoanPurpose,dummyOffice);
        system.debug('****LoanClient'+objLoanClient );
        
        test.startTest();
        LineOfCreditExpiryJob  objLineCredit =  new LineOfCreditExpiryJob();
        ID batchprocessid = Database.executeBatch(objLineCredit);
        String jobId = System.schedule('TestLineOfCreditExpiryJob',

                        CRON_EXP,

                        new LineOfCreditExpiryJob ());
                                           
        test.stopTest();
     }
}