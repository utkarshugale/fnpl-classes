@isTest
public class Test_WSLocAccounts_v1 {
  
   public static Contact objCon(){
    Contact  objContact = new Contact();
    objContact.FirstName = 'testContact1';
    objContact.LastName  = 'TestContact2';
    return objContact;
   }
   
    @isTest static void test_method_WSLocAccounts_v1_0_0() {
        // Implement test code
        Map<String,Object> reqBodyMap = new Map<String,Object>();
        reqBodyMap.put('borrowerId1', '123456789012345');
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
         Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }

    @isTest static void test_method_WSLocAccounts_v1_0() {
        // Implement test code
       Contact objCon = Test_WSLocAccounts_v1.objCon();
       insert objCon ;
        Map<String,Object> reqBodyMap = new Map<String,Object>();
        reqBodyMap.put('borrowerId', objCon.id);
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBodyMap));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
         Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }

   
  @isTest static void test_method_WSLocAccounts_v1_1() {
        // Implement test code
        Contact objCon = Test_WSLocAccounts_v1.objCon();
        insert objCon ;
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }

    
    @isTest static void test_method_WSLocAccounts_v1_2() {
        // Implement test code
        Contact objCon = Test_WSLocAccounts_v1.objCon();
        insert objCon ;
        Map<String,Object> reqBodyMap = new Map<String,Object>();
        reqBodyMap.put('borrowerId', null);
        reqBodyMap.put('loanProductId',objCon.id);
        reqBodyMap.put('loanAmount', 1200);
        reqBodyMap.put('term',3);
        reqBodyMap.put('interestRate',3);
        reqBodyMap.put('purpose','testing');
        reqBodyMap.put('expectedDisbursalDate',date.today());
        reqBodyMap.put('firstInstallmentDate',date.today());
        reqBodyMap.put('frequencyOfPayment', '2');
        reqBodyMap.put('interestOnlyPeriod', 3);
        reqBodyMap.put('balloonPayment', 123);
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBodyMap));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
         Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }


    @isTest static void test_method_WSLocAccounts_v1_3() {
        // Implement test code
         Contact objCon = Test_WSLocAccounts_v1.objCon();
         insert objCon ;
        Map<String,Object> reqBodyMap = new Map<String,Object>();
        reqBodyMap.put('borrowerId',objCon.id);
        reqBodyMap.put('loanProductId',string.valueOf(objCon.id));
        reqBodyMap.put('loanAmount', null);
        reqBodyMap.put('term',3);
        reqBodyMap.put('interestRate',3);
        reqBodyMap.put('purpose','testing');
        reqBodyMap.put('expectedDisbursalDate',date.today());
        reqBodyMap.put('firstInstallmentDate',date.today());
        reqBodyMap.put('frequencyOfPayment', '2');
        reqBodyMap.put('interestOnlyPeriod', 3);
        reqBodyMap.put('balloonPayment', 123);
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBodyMap));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
         Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }

    @isTest static void test_method_WSLocAccounts_v1_4() {
        // Implement test code
       Contact objCon = Test_WSLocAccounts_v1.objCon();
       insert objCon ;
        Map<String,Object> reqBodyMap = new Map<String,Object>();
        reqBodyMap.put('borrowerId',objCon.id);
        reqBodyMap.put('loanProductId',string.valueOf(objCon.id));
        reqBodyMap.put('loanAmount', 2000);
        reqBodyMap.put('term',null);
        reqBodyMap.put('interestRate',2);
        reqBodyMap.put('purpose','test');
        reqBodyMap.put('expectedDisbursalDate',date.today());
        reqBodyMap.put('firstInstallmentDate',date.today());
        reqBodyMap.put('frequencyOfPayment', '1');
        reqBodyMap.put('interestOnlyPeriod', 1);
        reqBodyMap.put('balloonPayment',2);
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBodyMap));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
         Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }
    
     @isTest static void test_method_WSLocAccounts_v1_5() {
       Contact objCon = Test_WSLocAccounts_v1.objCon();
       insert objCon ;
       
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
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLocProduct('testData',
         dummyOffice, dummyAccount, curr, dummyFeeSet,'TestData',2, 2, 'Test');
         
        dummyLP.loan__Payment_Application_Mode__c = loan.LoanConstants.LOAN_PAYMENT_APPLICATION_CURRENT_DUES;
        dummyLP.loan__Loan_Product_Type__c = 'Line of Credit';
        update dummyLP;
       
        Map<String,Object> reqBodyMap = new Map<String,Object>();
        reqBodyMap.put('borrowerId',objCon.id);
        reqBodyMap.put('loanProductId',string.valueOf(objCon.id));
        reqBodyMap.put('loanAmount', 2000);
        reqBodyMap.put('term',2);
        reqBodyMap.put('interestRate',2);
        reqBodyMap.put('purpose','test');
        reqBodyMap.put('expectedDisbursalDate',date.today());
        reqBodyMap.put('firstInstallmentDate',date.today());
        reqBodyMap.put('frequencyOfPayment', '1');
        reqBodyMap.put('interestOnlyPeriod', 1);
        reqBodyMap.put('balloonPayment',2);
         RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBodyMap));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }
    
     @isTest static void test_method_WSLocAccounts_v1_6() {
       Contact objCon = Test_WSLocAccounts_v1.objCon();
       insert objCon ;
       
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
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLocProduct('testData',
         dummyOffice, dummyAccount, curr, dummyFeeSet,'TestData',2, 2, 'Test');
         
        dummyLP.loan__Payment_Application_Mode__c = loan.LoanConstants.LOAN_PAYMENT_APPLICATION_CURRENT_DUES;
        dummyLP.loan__Loan_Product_Type__c = 'Line of Credit';
        update dummyLP;
       
        Map<String,Object> reqBodyMap = new Map<String,Object>();
        reqBodyMap.put('borrowerId',null);
        reqBodyMap.put('loanProductId',string.valueOf(objCon.id));
        reqBodyMap.put('loanAmount', 2000);
        reqBodyMap.put('term',2);
        reqBodyMap.put('interestRate',2);
        reqBodyMap.put('purpose','test');
        reqBodyMap.put('expectedDisbursalDate',date.today());
        reqBodyMap.put('firstInstallmentDate',date.today());
        reqBodyMap.put('frequencyOfPayment', '1');
        reqBodyMap.put('interestOnlyPeriod', 1);
        reqBodyMap.put('balloonPayment',2);
         RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBodyMap));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }
    
    @isTest static void test_method_WSLocAccounts_v1_7() {
       Contact objCon = Test_WSLocAccounts_v1.objCon();
       insert objCon ;
       
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
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLocProduct('testData',
         dummyOffice, dummyAccount, curr, dummyFeeSet,'TestData',2, 2, 'Test');
         
        dummyLP.loan__Payment_Application_Mode__c = loan.LoanConstants.LOAN_PAYMENT_APPLICATION_CURRENT_DUES;
        dummyLP.loan__Loan_Product_Type__c = 'Line of Credit';
        update dummyLP;
       
        Map<String,Object> reqBodyMap = new Map<String,Object>();
        reqBodyMap.put('borrowerId',objCon.id);
        reqBodyMap.put('loanProductId',string.valueOf(objCon.id));
        reqBodyMap.put('loanAmount', 2000);
        reqBodyMap.put('term',2);
        reqBodyMap.put('interestRate',2);
        reqBodyMap.put('purpose','test');
        reqBodyMap.put('expectedDisbursalDate',date.today());
        reqBodyMap.put('firstInstallmentDate',date.today());
        reqBodyMap.put('frequencyOfPayment', '1');
        reqBodyMap.put('interestOnlyPeriod', 1);
        reqBodyMap.put('balloonPayment',2);
         RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/lineofcredit';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBodyMap));
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Response results = WSLocAccounts_v1.createLoanAccount();
        Test.stopTest();
    }
    
}