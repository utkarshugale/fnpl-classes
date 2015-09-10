public class ShareInsightFormatGen extends loan.FileGenerator {
    private Date systemDate;
    private loan.GlobalLoanUtilFacade facade;
    private SHARE__c shareParams;
    
    public override String getSimpleFileName() {
        return 'Credit_Report'+'_'+System.now();
    }

    public ShareInsightFormatGen(){
        super();
        
        facade = new loan.GlobalLoanUtilFacade();
        systemDate = facade.getCurrentSystemDate();
        
        //get custom settings
        shareParams = SHARE__c.getOrgDefaults();
    }
    
    private Entry_Record__c generateEntryDetailRecord(loan__Loan_Account__c loan){
        Entry_Record__c rec = new Entry_Record__c(Name = loan.Name);
        
        //Record Code : Custom settings.
        rec.Record_Code__c = '2001D';
        
        //Company ID : custom Settings.
        rec.Company_ID__c = shareParams.Company_ID__c;
        
        //Company Type : Custom Settings.
        rec.Company_Type__c = sharePArams.Company_Type__c;
        
        //Account Type : Hardcoded.
        rec.Account_Type__c = '05';
        
        //Account Number : Loan Name
        rec.Account_Number__c = loan.Name;
        
        //Start Date: Date of Agreement.
        rec.Start_Date__c = loan.loan__Disbursal_Date__c;
        
        //Current Status : Current Status Field on Loan.
        rec.Current_Status__c = getCurrentLoanStatus(loan);
        
        if(rec.Current_Status__c.equalsIgnoreCase('D')) {
            //Default Date: Date of bad standing.
            rec.Default_Date__c = loan.loan__Metro2_First_Delinquency_Date__c;
            
            //Default : Loan Account - Delinquent Amount [To Fix]
            rec.Default_Balance__c = loan.Delinquent_Amount_Snapshot__c;
        }
        
        //End Date: for settled : Pay off date
        //        : for Default : Date on which Loan Account got default
        //        : for Good    : 00000000
        if(loan.loan__Loan_Status__c.equalsIgnoreCase('Closed - Obligations met')) {
            System.debug(LoggingLevel.eRROR,' Date 1 ' +rec.End_Date__c+' '+loan.name);
            rec.End_Date__c = loan.loan__Last_Payment_Date__c;
        } else if(loan.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                    && rec.Current_Status__c.equalsIgnoreCase('D')) {
            System.debug(LoggingLevel.eRROR,' Date 2 ' +rec.End_Date__c+' '+loan.name);
            //Date on which loan account is defaulted.
            rec.End_Date__c = loan.loan__Metro2_First_Delinquency_Date__c;
        } else if(loan.loan__Loan_Status__c.equalsIgnoreCase('Closed- Written Off')) {
            //Date on which loan account is defaulted.
            rec.End_Date__c = loan.loan__Metro2_First_Delinquency_Date__c;
            System.debug(LoggingLevel.eRROR,' Date 3 ' +rec.End_Date__c+' '+loan.name);
        } else if(loan.loan__Loan_Status__c.equalsIgnoreCasE('Active - Good Standing')) {
            System.debug(LoggingLevel.eRROR,' Date 4 ' +rec.End_Date__c+' '+loan.name);
            rec.End_Date__c = null;
        }
        
        //Birth Date : Contact
        rec.Birth_Date__c = loan.loan__Contact__r.Birthdate;
        
        //Credit Limit : Loan Account Credit Limit
        rec.Credit_Limit__c = loan.loan__Credit_Limit__c;
        
        //Flags : Loan Account, Flags.
        rec.Flag__c = !String.isEmpty(loan.Flag__c) ? '' : loan.Flag__c;
        
        //Spare : Length 3 : Padding.
        rec.Spare1__c = '';
        
        //Transient Association : Hardcoded 'T'
        rec.Transient_Association_Flag__c = '';
        
        //spare : Length 4 : padding.
        rec.Spare2__c = '';
        
        //Special Indicator : Address Change : 1 : L
        rec.Special_Indicator__c = '';
        
        //Current Balance : Today`s Payoff : Loan Account.
        Decimal curBal = loan.loan__Pay_Off_Amount_As_Of_Today__c.setScale(0);
        rec.Current_Balance__c = curBal;
        
        //Current Balance Sign : Hardcoded : ' ' (Blank Space).
        rec.Current_Balance_Sign__c = ' ';
        
        //Start Balance : Loan Account - 00
        rec.Start_Balance__c = 00;
        
        //Repayment Value : Current Payment Amount.
        rec.Repayment_Value__c = 00;
        
        //Repayment Period: Term from Loan Account.
        rec.Repayment_Period__c = loan.loan__Term_Cur__c;
        
        //Repayment Frequency : Loan Account
        rec.Repayment_Frequency__c = getRepaymentFrequency(loan.loan__Frequency_of_Loan_Payment__c);
        
        
        
        //Name Details : Contact Object.
        rec.Name_Details__c = getBorrowerName(loan.loan__Contact__r);
        System.debug(LoggingLevel.ERROR,' Name '+rec.Name_Details__c);
        
        //Address : contact [To Do]
        rec.Address_Line1__c = loan.loan__Contact__r.MailingStreet;
        rec.Address_Line2__c = loan.loan__Contact__r.MailingCity;
        rec.Address_Line3__c = loan.loan__Contact__r.MailingState;
        rec.Address_Line4__c = '';
        rec.Postcode__c = loan.loan__Contact__r.MailingPostalCode;
        
        //Spare : Length 8 : padding.
        rec.Spare3__c = '';
        
        //New Account Number : Unchanged : Padding.
        rec.New_Account_Number__c = '';
        
        //UseR Own Data : Padding 175.
        rec.User_Own_Data__c = '';
        

        return rec;
    }
    
    private String getCurrentLoanStatus(loan__Loan_Account__c la) {
        if(la.Current_Status__c != null){
            return la.Current_Status__c;
        }else if(la.loan__Loan_Status__c.equalsIgnoreCasE('Active - Good Standing')
            && la.loan__First_Installment_Date__c < systemDate) {
            return 'U';
        }else if(la.loan__Loan_Status__c.equalsIgnoreCasE('Active - Good Standing')
            && la.loan__First_Installment_Date__c > systemDate) {
            return 'O';
        }else if(la.loan__Loan_Status__c.equalsIgnoreCase('Closed - Obligations met')) {
            return 'S';
        }else if(la.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                   && la.loan__Number_of_Days_Overdue__c <= 30) {
            return '1';
        }else if(la.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                   && la.loan__Number_of_Days_Overdue__c > 30
                   && la.loan__Number_of_Days_Overdue__c <= 60) {
            return '2';
        }else if(la.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                   && la.loan__Number_of_Days_Overdue__c > 60
                   && la.loan__Number_of_Days_Overdue__c <= 90) {
            return '3';
        }else if(la.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                   && la.loan__Number_of_Days_Overdue__c > 90) {
            return 'D';
        }/*else if(la.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                   && la.loan__Number_of_Days_Overdue__c > 121) {
            return 'D';
        }else if(la.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                   && la.loan__Number_of_Days_Overdue__c > 151) {
            return 'D';
        }else if(la.loan__Loan_Status__c.equalsIgnoreCase('Active - Bad Standing')
                   && la.loan__Number_of_Days_Overdue__c > 181) {
            return 'D';
        }*/else if(la.loan__Loan_Status__c.equalsIgnoreCase('Closed- Written Off')) {
            return 'R';
        }
        
        return '';
    }
    
    private String getRepaymentFrequency(String frequency) {
        String retVal = 'M';
        
        if(frequency.equalsIgnoreCase('Monthly')){
            retVal = 'M';
        }else if(frequency.equalsIgnoreCase('Weekly')){
            retVal = 'W';
        }else if(frequency.equalsIgnoreCase('Quarterly')){
            retVal = 'Q';
        }else if(frequency.equalsIgnoreCase('Annually')) {
            retVal = 'A';
        }else {
            retVal = 'P';
        }
        
        return retVal;
    }
    
    public String getBorrowerName(Contact borrower) {
        String retVal = '';
        
        //surname,salutation,firstname,lastname,suffix.
        retVal = retVal + borrower.LastName + ',';
        retVal = retVal + (String.isEmpty(borrower.Salutation) ? '': borrower.Salutation )+',';
        retVal = retVal + (String.isEmpty(borrower.FirstName) ? '' : borrower.FirstName ) + ',';
        retVal = retVal + (String.isEmpty(borrower.MiddleName) ? '': borrower.MiddleName )+ ',';
        retVal = retVal + (String.isEmpty(borrower.Suffix) ? '' : borrower.Suffix);
        
        //Check name length
        if(retVal.length() > 42) {
            //Rule 1:
            if(borrower.suffix.equalsIgnoreCase('Junior')) {
                retVal = retVal.replace(borrower.suffix,'Jnr');
                System.debug(LoggingLevel.ERROR,' Rule 1 '+retVAl);
            }
            
            if(borrower.suffix.equalsIgnoreCase('Senior')) {
                retVal = retVal.replace(borrower.suffix,'Snr');  
                System.debug(LoggingLevel.ERROR,' Rule 1 '+retVAl); 
            }    
            
            //Rule 2 : unreachable.
            //Rule 3 : remove suffix.
            if(retVal.length() > 42) {
                retVal = retVal.removeEnd(borrower.suffix);
                System.debug(LoggingLevel.ERROR,' Rule 3'+retVAl);
            }
            
            //Rule 4: MiddleName initials
            if(retVal.length() > 42) {
                //retVal = retVal.replace(borrower.middleName,borrower.middleName.indexOfChar(borrower.middleName.charAt(0)));
                System.debug(LoggingLevel.ERROR,' Rule 4 '+retVAl);
            }
            
            //Rule 5: 
            if(retVal.length() > 42) {
                //retVal = retVal.removeEnd(borrower.middleName.charAt(0));
                System.debug(LoggingLevel.ERROR,' Rule 5 '+retVAl);
            }
            
            if(retVal.length() > 42) {
                //Replace first name with initials.
                System.debug(LoggingLevel.ERROR,' Rule 6 '+retVAl);
            }
        }
        
        System.debug(LoggingLevel.ERROR,' Name details '+retVAl);
        
        return retVal;
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
        retVal = segments.retString();
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
        headerRec.Record_Code__c = shareParams.Record_Code__c;
        headerRec.Company_ID__c = shareParams.Company_Id__c;
        headerRec.Company_Type__c = shareParams.Company_Type__c;
        
        Integer month = systemDate.month();
        String monthStr = (month < 10) ? '0'+ month : String.valueOf(month);                                  
        headerRec.Batch_Date__c = String.valueOf(systemDate.year())+monthStr;
                                         
        List<SObject> headerRecs = new List<SObject>();
        headerRecs.add(headerRec);
       
        filegen.CreateSegments segments =new filegen.CreateSegments(headerRecs);
        retVal = segments.retString();
        retVal[0] = retVal[0].removeEnd('\r\n');
        
        //Add Filler.
        for(Integer i = 0;i< 497;i++){
            retVal[0] = retVal[0] + ' ';
        }
        header =retVal[0]+'\n';
        return header;
        
    }
    
    public override String getTrailer(loan.TransactionSweepToACHState state, LIST<SObject> scope) {
        String trailer = '';
        List<String> retVal = new List<String>();
        
        Insight_Header_Trailer__c headerRec = [Select Id,Name,
                                                      Company_Type__c,
                                                      Company_Id__c,
                                                      Record_Code__c,
                                                      Batch_Date__c
                                               From Insight_Header_Trailer__c
                                               Where Record_Type__c = 'Header'];
        
        headerRec.Record_Code__c = '2001T';
        
        Integer month = systemDate.month();
        String monthStr = (month < 10) ? '0'+ month : String.valueOf(month);                                  
        headerRec.Batch_Date__c = String.valueOf(systemDate.year())+monthStr;
        
        List<SObject> headerRecs = new List<SObject>();
        headerRecs.add(headerRec);
       
        filegen.CreateSegments segments =new filegen.CreateSegments(headerRecs);
        retVal = segments.retString();
        
        //Add number of records at the end.
        String sizeString = scope.size()+'';
        
        if(sizeString.length() < 12) {
            for(Integer i = sizeString.length(); i < 12; i++) {
                sizeString = '0' + sizeString; 
            }
        }
        retVal[0] += sizeString;
        
        //Add Filler.
        for(Integer i = 0;i< 485;i++){
            retVal[0] = retVal[0] + ' ';
        }
        
        trailer =retVal[0]+'\n';
        return trailer;
        //return 'TRAILER';
    }
}