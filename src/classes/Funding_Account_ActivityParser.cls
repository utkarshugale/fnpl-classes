/*
   This file is indicate to Parse Csv file into Wrapper Data.
*/
public class Funding_Account_ActivityParser {

    //Passing File Content
    public Blob FileParser {
        get;
        set;
    }
    //Passing FileName
    public string strFileName {
        get;
        set;
    }
    //Converting file Formats to Separate columns.
    String[] filelines = new String[] {};

    // Csv Parser to Wrapperlist.
    public list <RefundFileWrapper> lstFundingAccountWrapper;

    //Constructor Calling
    public Funding_Account_ActivityParser() {
        lstFundingAccountWrapper = new list < RefundFileWrapper > ();
    }
    
    
    //Csv File to Parse to Wrapper List.
    public PageReference parseFile() {
    
        if(fileParser == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.SEVERITY.ERROR,'File incorrect or no file attached. Please upload valid CSV file.');
            ApexPages.addMessage(msg);
            return null;
        }
        
        strFileName = fileParser.tostring();
        
        LineReader lineReader = new LineReader(strFileName);
        List<String> strcolvalues;
        
        RefundFileWrapper objParser;
        
        while(lineReader.hasNext()) {
            objParser = new RefundFileWrapper();
            strcolvalues = new List<String>();
            
            // Read line
            String line = lineReader.next();
            system.debug('****line*****'+line);
            System.debug(LoggingLEvel.eRRoR,' line '+line);
            
            //Split each Column
            strcolvalues = line.split(',');
            objParser.strStartDate = strcolvalues[0];
            objParser.strTrasactionDate = strcolvalues[1];
            objParser.strCommunity = strcolvalues[2];
            objParser.strClient = strcolvalues[3];
            objParser.strTransactionId = strcolvalues[4];
            objParser.strAdjustmentId = strcolvalues[5];
            
            objParser.strTranctionType = strcolvalues[6];
            System.debug(LoggingLevel.ERROR,' Val '+objParser.strTranctionType);
            objParser.strTransactionCurrency = strcolvalues[7];
            objParser.strTransactionAmount = strcolvalues[8];
            objParser.strSourceType = strcolvalues[9];
            objParser.strSourceDetails = strcolvalues[10];
            objParser.strDestinationType = strcolvalues[11];
            objParser.strDestinationDetails = strcolvalues[12];
            objParser.strParticipantType = strcolvalues[13];
            objParser.strParticipantDetails = strcolvalues[14];
            objParser.strParticipantsink = strcolvalues[15];
            objParser.strOriginalCurrency = strcolvalues[16];
            objParser.strOriginalAmount = strcolvalues[17];
            objParser.strParticipantCurrency = strcolvalues[18];
            objParser.strParticipiantAmount = strcolvalues[19];
            objParser.strExchangeRate = strcolvalues[20];
            objParser.strNonForexFee = strcolvalues[21];
            objParser.strForexFee = strcolvalues[22];
            objParser.strBalanceBefore = strcolvalues[23];
            objParser.strBalanceAdjustement = strcolvalues[24];
            objParser.strBalanceAfter = strcolvalues[25];
            objParser.strStatus = strcolvalues[26];
            objParser.strForexFlag = strcolvalues[27];
            objParser.strDircetion = strcolvalues[28];
            objParser.strExternalRef = strcolvalues[29];
            objParser.strTransactionInfo = strcolvalues[30];
            objParser.strScenarioCases = strcolvalues[31];
            objParser.strSingleCases = strcolvalues[32];
            
            if(objParser.strTranctionType.trim().equalsIgnoreCase('MERCHANT REFUND')) {
                System.debug(LoggingLevel.ERROR,' Adding Refund ');
                lstFundingAccountWrapper.add(objParser);
            }
        }

        System.debug(LoggingLevel.ERROR,' txns to reverse '+lstFundingAccountWrapper.size());
        
        try {
            if(lstFundingAccountWrapper != null && !lstFundingAccountWrapper.isEmpty()) {
                RefundStatementHandler handler = new RefundStatementHandler(lstFundingAccountWrapper);
                handler.handleStatement();
            }else{
                ApexPages.Message msg = new ApexPages.Message(ApexPages.SEVERITY.INFO,'Uploaded file has no Refund Transactions. ');
                ApexPages.addMessage(msg);
                return null;
            }
        }catch(exception e){ 
            System.debug(LoggingLEvel.ERROR,' Error thrown from '+e.getlineNumber());
            ApexPages.Message msg = new ApexPages.Message(ApexPages.SEVERITY.ERROR,e.getMessage());
            ApexPages.addMessage(msg);
            return null;
        }
        
        ApexPages.Message msg = new ApexPages.Message(ApexPages.SEVERITY.CONFIRM,'Refund Statement processed successfully. Please check \'Refund Exception Report\' for exceptions.');
        ApexPages.addMessage(msg);
        
        return null;
    }

}