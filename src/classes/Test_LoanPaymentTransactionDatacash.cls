@isTest(SeeAllData=false)
public class Test_LoanPaymentTransactionDatacash{
    
    public  static void createSeedData() {
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
        contact con = new contact(firstname='testname',lastname='testsimha');
        insert con;
        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Contact__c=con.id;
        update loanAccount;
        loan__Payment_Mode__c payMode = new loan__Payment_Mode__c();
        payMode.Name='ACH';
        insert payMode;
       
        loan__Bank_Account__c bank = new loan__Bank_Account__c(loan__Contact__c=con.id,
                                                              loan__Bank_Name__c='test',
                                                              Bank_Card_Details__c='12345666',
                                                               Expiry_Month__c=9,
                                                               Expiry_Year__c=2,
                                                               CVV__c='901',
                                                              loan__Active__c=true,
                                                              loan__Bank_Account_Number__c='1234567112');
        insert bank;
        //Create Loan Payment Transaction
        loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
        lpt.loan__Loan_Account__C = loanAccount.Id;
        lpt.Datacash_Reference__c   =   '4700204413909570'    ;
        lpt.loan_ffa__Create_Journal__c =   FALSE   ;
        lpt.loan_ffa__Dishonor_Fee_Journal_Created__c   =   FALSE   ;
        lpt.loan_ffa__Dishonor_Fee_Reversal_Journal_Created__c  =   FALSE   ;
        lpt.loan_ffa__Late_Fee_Journal_Created__c   =   FALSE   ;
        lpt.loan_ffa__Late_Fee_Reversal_Journal_Created__c  =   FALSE   ;
        lpt.loan__Balance__c    =   6879.6  ;
        lpt.loan__Custom_Logic__c   =   FALSE   ;
        lpt.loan__Dues_Snapshot__c  =   'a3b250000008OniAAE=DPPD_#DP_271.57:a3b250000008OntAAE=DPPD_#DP_271.5700:'    ;
        lpt.loan__Early_Payment__c  =   FALSE   ;
        lpt.loan__Early_Total_Repayment_of_the_Loan__c  =   FALSE   ;
        lpt.loan__Excess__c =   0   ;
        lpt.loan__Fees__c   =   24  ;
        lpt.loan__Fee_Snapshot__c   =   'a27250000008QSsAAM=CLAD_#CP_12.0000#CIP_0.0000#CID_0.0000#CPP_12.0000:a27250000008QT8AAM=CLAD_#CP_12.0000#CIP_0.0000#CID_0.0000#CPP_12.0000: '   ;
        lpt.loan__Interest__c   =   402.74  ;
        lpt.loan__Late_Charge_Interest__c   =   0   ;
        lpt.loan__Late_Charge_Principal__c  =   24  ;
        lpt.loan__Loan_Snapshot__c  =   'NDD_2015/1/10#NDGD_2015/1/10#CPA_0.00#NRCD_3000/12/31#TP_7520.57501#RAFNDD_0.00#LPA_0.00#LPD_#LDD_2014/12/10#LAD_2014/12/10#LID_34.9000#ASD_2014/10/11#MDC_2015/10/10#CT_12#LS_Active - Bad Standing#DPD_41#DA_543.13644#ODD_2014/11/10#E_0.00000#LTT_Billing#LTTS_10/12/2014 01:01#PPI_0.00000#PPTD_#POD_#FDD_2014/11/10#PP_0.00000#FP_0.00000#IP_0.00000#IW_0.00000#PR_7020.00000#FR_24.00000#IR_402.74#R_false#D_true#LTID_null'  ;
        lpt.loan__Manual_Payment__c =   FALSE   ;
        lpt.loan__Missed_Loan_Installment__c    =   FALSE   ;
        lpt.loan__Other_Charges_Interest__c =   0   ;
        lpt.loan__Other_Charges_Principal__c    =   0   ;
        lpt.loan__Paid_to_Broker_Reversed__c    =   FALSE   ;
        lpt.loan__Paid_to_Broker__c =   FALSE   ;
        lpt.loan__Paid_to_Investor_Reversed__c  =   FALSE   ;
        lpt.loan__Paid_to_Investor__c   =   FALSE   ;
        lpt.loan__Partial_Payment_del__c    =   FALSE   ;
        lpt.loan__Payment_Application_Mode__c   =   'Future Dues' ;
        lpt.loan__Payment_Mode__c   = payMode.Id  ;
        lpt.loan__Principal__c  =   140.4   ;
        lpt.loan__Receipt_Date__c   =   SYSTEM.TODAY().ADDDAYS(-365)  ;
        lpt.loan__Rejected__c   =   FALSE   ;
        lpt.loan__Reversed__c   = false;
        lpt.loan__Sent_to_ACH__c    =   FALSE   ;
        lpt.loan__Skip_Validation__c    =   FALSE   ;
        lpt.loan__Total_Charges_Interest__c =   0   ;
        lpt.loan__Total_Charges_Principal__c    =   24  ;
        lpt.loan__Transaction_Amount__c =   567.14  ;
        lpt.loan__Transaction_Date__c   =   date.today() ;
        lpt.loan__Transaction_Time__c   =   SYSTEM.NOW();
        lpt.loan__Write_Off_Recovery_Payment__c =   FALSE   ;
        lpt.Merchant_Reference__c   =   'NwqlNFWN0'   ;
        lpt.peer__Loan_Cancellation__c  =   FALSE   ;
        lpt.loan__Sent_To_Ach__c =false;
        lpt.peer__Verified_From_Bank_Statement__c   =   FALSE   ;
        lpt.Refunded__c =   FALSE    ;
        lpt.loan__Cleared__c = false;
        
        insert lpt;
       lpt.loan__Cleared__c = false;
        
        update lpt;
        Datacash_Config__c config = new Datacash_Config__c(Password__c='ACc5E3PMyv',
                                                           Server_Url__c='https://testserver.datacash.com/Transaction',
                                                           Username__c='99008281'
                                                            );
        insert config;
        
        //Reverse this txn.
       /* Set<Id> loanPaymentIds = new Set<ID>();
        loanPaymentIds.add(lpt.id);
        
        loan.LoanActionFactory factory = new loan.LoanActionFactory();
        loan.LoanAction2 impl = factory.getLoanAction2API();
        impl.reverseLoanPayment(loanPaymentIds,'','');*/
    }
    
    @isTest
    public static void Test_LoanPaymentTransaction(){
        createSeedData();
        

        test.startTest();  
            Test.setMock(HttpCalloutMock.class, new MockHttpLoanpaymentDatacash());
              //string con_exp= '0 0 1 * * ?';
              //System.schedule('batchOpp_Delete', con_exp, new LoanPaymentTransactionSweepToDatacash());  
              LoanPaymentTransactionSweepToDatacash  loanPayment = new LoanPaymentTransactionSweepToDatacash ();
              ID batchprocessid = Database.executeBatch(loanPayment );
              test.stopTest();
    }
}