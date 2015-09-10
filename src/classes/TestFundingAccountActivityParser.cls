@istest
public class TestFundingAccountActivityParser {

    public static String testString = 'startDate,transactionDate,community,client,transactionID,adjustmentID,transactionType,transactionCurrency,transactionAmount,sourceType,sourceDetails,destinationType,destinationDetails,participantType,participantDetails,participantSink,originalCurrency,originalAmount,participantCurrency,participantAmount,exchangeRate,nonForexFee,forexFee,balanceBefore,balanceAdjustment,balanceAfter,status,forexFlag,direction,merchantName,merchantCountry,merchantCategoryCode,acquirerReferenceNumber,authCode,providerDate,externalRef,externalID,cardNum,cardScheme,cardFactoryName,customField1,customField2,customField3,customField4,customField5,transactionInfo,scenarioCases,singleCases'+ '\n' +
                    '07/07/14 19:02,07/07/14 19:02,ClientA,ClientA#ClientA,9.21E+16,9.21E+16,CARD CREATED,EUR,636.84,Funding Account,faClientAEUR,Virtual Card,ClientAvisa.P6HDHM3RR40,Virtual Card,ClientAvisa.P6HDHM3RR40,DESTINATION,EUR,636.84,EUR,636.84,1,0,0,0,636.84,636.84,COMPLETED,N,A,,,,,,,0UwEa4KEnDGEemjzji0aoq_Kv,,446221******2485,VISA,ClientAvisa,,,,,,,5100,1200'+'\n' +
                    '08/07/14 16:09,08/07/14 16:09,ClientA,ClientA#ClientA,9.21E+16,,AUTHORISATION,EUR,-606.51,Virtual Card,ClientAvisa.P6HDHM3RR40,,,Virtual Card,ClientAvisa.P6HDHM3RR40,SOURCE,EUR,-606.51,EUR,0,1,0,0,0,0,0,COMPLETED,N,A,AIR ONE CALL CENTER      ROMA       RMIT,IT,3013,,929566,07/07/14 0:00,0UwEa4KEnDGEemjzji0aoq_Kv,,446221******2485,VISA,ClientAvisa,,,,,,NORMAL_TAKE,5100,1400'+'\n' +
                    '11/07/14 16:11,11/07/14 16:11,ClientA,ClientA#ClientA,9.21E+16,9.21E+16,PURCHASE,EUR,-25,Virtual Card,ClientAvisa.P6HDHM3RR40,,,Virtual Card,ClientAvisa.P6HDHM3RR40,SOURCE,EUR,-25,EUR,-25,1,0,0,636.84,-25,611.84,COMPLETED,N,A,AIR ONE CAL 0554707171442/AIR ONE CALL/,IT,3013,7.49E+22,929566,11/07/14 0:00,0UwEa4KEnDGEemjzji0aoq_Kv,,446221******2485,VISA,ClientAvisa,,,,,,,5100,1600'+'\n' +
                    '11/07/14 16:11,11/07/14 16:11,ClientA,ClientA#ClientA,9.21E+16,9.21E+16,PURCHASE,EUR,-187.04,Virtual Card,ClientAvisa.P6HDHM3RR40,,,Virtual Card,ClientAvisa.P6HDHM3RR40,SOURCE,EUR,-187.04,EUR,-187.04,1,0,0,611.84,-187.04,424.8,COMPLETED,N,A,AIR ONE CAL 0558502885871/AIR ONE CALL/,IT,3013,7.49E+22,929566,11/07/14 0:00,0UwEa4KEnDGEemjzji0aoq_Kv,,446221******2485,VISA,ClientAvisa,,,,,,,5100,1600'+'\n' +
                    '11/07/14 16:11,11/07/14 16:11,ClientA,ClientA#ClientA,9.21E+16,9.21E+16,PURCHASE,EUR,-187.04,Virtual Card,ClientAvisa.P6HDHM3RR40,,,Virtual Card,ClientAvisa.P6HDHM3RR40,SOURCE,EUR,-187.04,EUR,-187.04,1,0,0,424.8,-187.04,237.76,COMPLETED,N,A,AIR ONE CAL 0558502885872/AIR ONE CALL/,IT,3013,7.49E+22,929566,11/07/14 0:00,0UwEa4KEnDGEemjzji0aoq_Kv,,446221******2485,VISA,ClientAvisa,,,,,,,5100,1600'+'\n' +
                    '11/07/14 16:11,11/07/14 16:11,ClientA,ClientA#ClientA,9.21E+16,9.21E+16,PURCHASE,EUR,-25,Virtual Card,ClientAvisa.P6HDHM3RR40,,,Virtual Card,ClientAvisa.P6HDHM3RR40,SOURCE,EUR,-25,EUR,-25,1,0,0,237.76,-25,212.76,COMPLETED,N,A,AIR ONE CAL 0554707171441/AIR ONE CALL/,IT,3013,7.49E+22,929566,11/07/14 0:00,0UwEa4KEnDGEemjzji0aoq_Kv,,446221******2485,VISA,ClientAvisa,,,,,,,5100,1600'+'\n' +
                    '11/07/14 16:11,11/07/14 16:11,ClientA,ClientA#ClientA,9.21E+16,9.21E+16,PURCHASE,EUR,-182.43,Virtual Card,ClientAvisa.P6HDHM3RR40,,,Virtual Card,ClientAvisa.P6HDHM3RR40,SOURCE,EUR,-182.43,EUR,-182.43,1,0,0,212.76,-182.43,30.33,COMPLETED,N,A,AIR ONE CAL 0558502885873/AIR ONE CALL/,IT,3013,7.49E+22,929566,11/07/14 0:00,0UwEa4KEnDGEemjzji0aoq_Kv,,446221******2485,VISA,ClientAvisa,,,,,,,5100,1600'+'\n' +
                    '11/07/14 16:16,11/07/14 16:16,ClientA,ClientA#ClientA,9.21E+16,9.21E+16,CARD DELETED,EUR,30.33,Virtual Card,ClientAvisa.P6HDHM3RR40,Funding Account,faClientAEUR,Virtual Card,ClientAvisa.P6HDHM3RR40,SOURCE,EUR,-30.33,EUR,-30.33,1,0,0,30.33,-30.33,0,COMPLETED,N,A,,,,,,,0UwEa4KEnDGEemjzji0aoq_Kv,,446221******2485,VISA,ClientAvisa,,,,,,,5100,1300'+'\n' +
                    '22/07/14 10:38,22/07/14 10:38,ClientG,ClientD#ClientD,9.21E+16,,CARD CREATED,GBP,0,Funding Account,faClientDGBP,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,DESTINATION,GBP,0,GBP,0,1,0,0,0,0,0,COMPLETED,N,A,,,,,,,0UwGIveFM8bGAFst_X5yyfNpQ,,446221******1996,VISA,vsdeb18mss,,,,,,,5200,1205'+'\n' +
                    '22/07/14 10:38,22/07/14 10:38,ClientG,ClientD#ClientD,9.21E+16,9.21E+16,TRANSFER,GBP,275.96,Funding Account,faClientDGBP,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,DESTINATION,GBP,275.96,GBP,275.96,1,0,0,0,275.96,275.96,COMPLETED,N,A,,,,,,,0UwGIveFM8bGAFst_X5yyfNpQ,,446221******1996,VISA,vsdeb18mss,,,,,,,5200,100'+'\n' +
                    '23/07/14 16:06,23/07/14 16:06,ClientG,ClientD#ClientD,9.22E+16,,AUTHORISATION,GBP,-275.96,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,,,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,SOURCE,GBP,-275.96,GBP,0,1,0,0,0,0,0,COMPLETED,N,A,AER LINGUS               DUBLIN       IE,IE,3043,,153173,22/07/14 0:00,0UwGIveFM8bGAFst_X5yyfNpQ,,446221******1996,VISA,vsdeb18mss,,,,,,NORMAL_TAKE,5200,1400'+'\n' +
                    '25/07/14 16:12,25/07/14 16:12,ClientG,ClientD#ClientD,9.22E+16,9.22E+16,PURCHASE,GBP,-275.96,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,,,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,SOURCE,GBP,-275.96,GBP,-275.96,1,0,0,275.96,-275.96,0,COMPLETED,N,A,AERLING     23RS2F TESTER/DUBLIN/,GB,3043,7.41E+22,153173,25/07/14 0:00,0UwGIveFM8bGAFst_X5yyfNpQ,,446221******1996,VISA,vsdeb18mss,,,,,,,5200,1600'+'\n' +
                    '25/07/14 16:12,25/07/14 16:12,ClientG,ClientD#ClientD,9.22E+16,,CARD DELETED,GBP,0,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,Funding Account,faClientDGBP,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,SOURCE,GBP,0,GBP,0,1,0,0,0,0,0,COMPLETED,N,A,,,,,,,0UwGIveFM8bGAFst_X5yyfNpQ,,446221******1996,VISA,vsdeb18mss,,,,,,,5200,1302'+ '\n' +
                    '30/07/14 16:10,30/07/14 16:10,ClientG,ClientD#ClientD,9.22E+16,9.22E+16,MERCHANT REFUND,GBP,100,,,Virtual Card,0RACI_D8GBZeiKne-aQDNwV52,Virtual Card,30e680b7-77ab-4802-aa9b-93c20668df66,DESTINATION,GBP,72,GBP,72,1,0,0,0,72,72,COMPLETED,N,A,AER LINGUCB/DUBLIN/,GB,3043,7.41E+22,1100,30/07/14 0:00,0UwGIveFM8bGAFst_X5yyfNpQ,,446221******1996,VISA,vsdeb18mss,,,,,,,5200,1700';
    public static loan__Loan_Account__c loanAccount;
    
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
        pMode.Name = 'Refund';
        insert pMode;
        
    }
    
    public static testMethod void runPositiveTests() {
        
        //Create SeedData 
        //createSeedData();
        
        //Run Test
        Test.StartTesT();
            
            Funding_Account_ActivityParser parser = new Funding_Account_ActivityParser();
            parser.fileParser = Blob.valueOf(testString);
            parser.parseFile();
            
        Test.StopTest();
        
        
    
    }
    
    public static testMethod void runPositiveTests1() {
        
        //Create SeedData 
        //createSeedData();
        
        loanAccount = [Select Id,Name from loan__Loan_Account__c limit 1];
        
        //Create Virtual Card.
        Virtual_Card__c vCard = new Virtual_Card__c();
        vCard.Loan_Account__c = loanAccount.Id;
        vCard.Card_Reference__c = '0RACI_D8GBZeiKne-aQDNwV52';
        
        insert vCard;
        
        //Run Test
        Test.StartTesT();
            
            Funding_Account_ActivityParser parser = new Funding_Account_ActivityParser();
            parser.fileParser = Blob.valueOf(testString);
            parser.parseFile();
            
            parser.parseFile();
            
        Test.StopTest();
        
        
    
    }
}