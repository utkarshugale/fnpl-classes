public class OIFormatGen extends loan.FileGenerator {
    private Date systemDate;
    private loan.GlobalLoanUtilFacade facade;
    private SHARE__c shareParams;
    
    public override String getSimpleFileName() {
        return 'OI_Report'+'_'+System.now();
    }

    public OIFormatGen(){
        super();
        
        facade = new loan.GlobalLoanUtilFacade();
        systemDate = facade.getCurrentSystemDate();
        
    }
    
    private OI_Entry_Record__c generateEntryDetailRecord(loan__Loan_Account__c loan){
        OI_Entry_Record__c rec = new OI_Entry_Record__c();
        
        //1. Reference Number - Loan Account Number - 19
        rec.OI_Account_Number__c = loan.Name;
        
        //2. Name - Contact Name - 120
        rec.OI_Title__c = (loan.loan__Contact__r.salutation != null) ? loan.loan__Contact__r.salutation : '';
        rec.OI_Forename__c = loan.loan__Contact__r.FirstName;
        rec.OI_Other_Name__c = (loan.loan__Contact__r.MiddleName != null) ? loan.loan__Contact__r.MiddleName : '';
        rec.OI_Surname__c = loan.loan__Contact__r.LastName;
        rec.OI_Suffix__c = (loan.loan__Contact__r.suffix != null) ? loan.loan__Contact__r.suffix : '';
        
        //3. Full Address - Mailing Address on Contact. - 168
        rec.OI_Address_Line1__c = loan.loan__Contact__r.MailingStreet;
        rec.OI_Address_Line2__c = loan.loan__Contact__r.MailingCity;
        rec.OI_Address_Line3__c = loan.loan__Contact__r.MailingState;
        rec.OI_Address_Line4__c = '';
        rec.OI_Address_Line5__c = '';
        rec.OI_Postcode__c = loan.loan__Contact__r.MailingPostalCode;
        
        //4. Previous Address - Not reporting. blank. - 168
        rec.Previous_Address__c = '';
        
        //5. Previous Address2 - Not Reporting. - 168
        rec.Previous_Address_2__c = '';
        
        //6. Date of Birth - Contact DOB - 8
        rec.OI_Birth_Date__c = loan.loan__Contact__r.Birthdate;
        
        //7. Declared Amount - Signed amount to nearest rounded pound. - 9
        rec.OI_Declared_Salary__c = 100000000;
        
        //8. Salary Net/Gross - 1
        rec.Salary_Net_Gross__c = 'G';
        
        //9. Account Type - cc - 2
        rec.OI_Account_Type__c = 'CC';
        
        //10. Consent To Data Sharing - Yes/No - 1
        rec.Consent_To_Data_Sharing__c = 'Y';
        
        //11. Number of Account Holders - no. of applicants - 2
        rec.Number_of_Account_Holders__c = 1;
        
        //12. Date of application - YYYYMMDD - 8
        rec.OI_Date_of_Application__c = loan.loan__Disbursal_Date__c;
        
        //13. Salary Verified - Y/N - 1
        rec.OI_Salary_Verified__c = 'Y';
        
        
        System.debug(LoggingLevel.ERROR,' Returning row '+rec);
        return rec;
    }
    
    public override List<String> getEntries(loan.TransactionSweepToACHState state, List<SObject> scope) {
        System.debug(loggingLevel.Error,'----:'+'inside entries');
        
        List<String> retVal = new List<String>();
        List<loan__Loan_Account__c> loans = (List<loan__Loan_Account__c>)scope;
        List<SObject> objects = new List<SObject>();
        
        for(loan__Loan_Account__c loan : loans){
            
            system.debug(loggingLevel.Error,'----:'+'inside entries for loop');
            addToValidScope(loan);
            objects.add(generateEntryDetailRecord(loan));           
            
        }
        
        filegen.CreateSegments segments = new filegen.CreateSegments(objects);
        System.debug(LoggingLevel.ERROR,' Segment '+segments);
        retVal = segments.retString();
        
        System.debug(' Ret Val '+retVal);
        for(String line : retVal){
            line = line+'\n';
            addEntry(line);
        }
        System.debug(LoggingLevel.ERROR,' Finished Entries ');
        return retVal;
    }
    
    public override String getHeader(loan.TransactionSweepToACHState state, List<SObject> scope) {
        String header = '';
        List<String> retVal = new List<String>();
        
        Insight_Header_Trailer__c headerRec = new Insight_Header_Trailer__c();
        headerRec.Record_Code__c = '';
        headerRec.Company_ID__c = '';
        headerRec.Company_Type__c = '';
                                         
        List<SObject> headerRecs = new List<SObject>();
        headerRecs.add(headerRec);
       
        filegen.CreateSegments segments =new filegen.CreateSegments(headerRecs);
        
        retVal = segments.retString();
        retVal[0] = retVal[0].removeEnd('\r\n');
        
        //Add Filler.
        for(Integer i = 0;i< 497;i++){
            retVal[0] = retVal[0] + ' ';
        }
        header = '';
        return header;
        
    }
    
    public override String getTrailer(loan.TransactionSweepToACHState state, LIST<SObject> scope) {
        String trailer = '';
        List<String> retVal = new List<String>();
        
        Insight_Header_Trailer__c headerRec = new Insight_Header_Trailer__c();
        headerRec.Record_Code__c = '';
        headerRec.Company_ID__c = '';
        headerRec.Company_Type__c = '';
        
        List<SObject> headerRecs = new List<SObject>();
        headerRecs.add(headerRec);
       
        filegen.CreateSegments segments =new filegen.CreateSegments(headerRecs);
        retVal = segments.retString();
        
        trailer = '';
        return trailer;
        //return 'TRAILER';
    }
}