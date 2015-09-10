@isTest (SeeAllData=True)
public class Test_Web_to_casecontroller {
    
    private static loan__Loan_Account__c dummyLoanAccount = new loan__Loan_Account__c();
    
    
    private static void createDummyData(){
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
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLocProduct('LOC Product',
                            dummyOffice,
                            dummyAccount, 
                            curr, 
                            dummyFeeSet,
                            'Interest Only',
                            12,
                            12,
                            null);
        
        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();    
        
        Contact Markus = new Contact();
         Markus.LastName = 'Markus';
         Markus.Email = 'dummy@dummy.com';
         insert Markus;
        
        system.debug('Markus'+Markus);
        dummyLoanAccount = loan.TestHelper.createLoanAccountForContact(dummyLP, Markus, dummyFeeSet,dummyLoanPurpose,dummyOffice);
        System.debug('dummyLoanAccount: '+dummyLoanAccount);
        //dummyLoanAccount.Name = 'LAI-00000001';
        update dummyLoanAccount;
        System.debug('dummyLoanAccountName: '+dummyLoanAccount.Name);

    }
    
    private static testMethod void testCreateCases() {
       // createDummyData();
        WebToCaseController AC= new WebToCaseController();
        AC.checkLA ='LAI-00000061';
        System.debug('WebToCaseController : '+AC.checkLA);

        AC.Create_case();
        
        
    } 
}