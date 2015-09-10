@isTest
public class TestRepaymentReversalTriggerHandler {
    
    public static loan__Loan_Account__c loanAccount;
    public static Date systemDate;
    
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
        
        //BorrowerImpl b = new BorrowerImpl();
        //b.disburseLocAccount(systemDate,loanAccount.loan__Credit_Limit__c,loanAccount,null,null);
        loanAccount.loan__Loan_Status__C = 'Active - Good Standing';
        loanAccount.loan__Principal_Remaining__c = loanAccount.loan__credit_limit__c;
        
        update loanAccount;
        
        //Create Virtual Card.
        Virtual_Card__c vCard = new Virtual_Card__c();
        vCard.Loan_Account__c = loanAccount.Id;
        vCard.Card_Reference__c = '0RACI_D8GBZeiKne-aQDNwV52';
        
        insert vCard;
        
        loan__Payment_Mode__C pMode = new loan__Payment_Mode__C();
        pMode.Name = 'Refund';
        insert pMode;
        
        systemDate = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
    }

    public static tesTMethod void runPositiveTests() {
        
        loanAccount = [Select Id,Name from loan__Loan_Account__c limit 1];
        
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
        lpt.loan__Loan_Account__c = loanAccount.Id;
        lpt.loan__Transaction_Amount__c = 200;
        lpt.loan__Payment_Mode__c = [Select Id,Name from loan__Payment_Mode__c Where Name = 'Cash'].Id;
        lpt.loan__Transaction_Date__c = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
        
        insert lpt;
        
        lpt.loan__Cleared__C = true;
        
        update lpt;
        
        set<Id> revIds = new SeT<ID>();
        revIds.add(lpt.Id);
        
        Test.startTest();
            loan__Repayment_Transaction_Adjustment__c loanAdjustment = new loan__Repayment_Transaction_Adjustment__c();
            loanAdjustment.loan__Loan_Payment_Transaction__c = lpt.Id;
            loanAdjustment.loan__Adjustment_Txn_Date__c = new loan.GlobalLoanUtilFacade().getCurrentSystemDate();
            loanAdjustment.loan__Reason_Code__c = 'Error';
            loanAdjustment.loan__Reference__c = 'ewrer';
            loanAdjustment.Attempt_Retry__c = true;
            
            insert loanAdjustment;
        Test.stopTest();
        
    }
}