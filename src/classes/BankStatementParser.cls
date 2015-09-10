global with sharing class BankStatementParser implements peer.IBankStatementParser{
    
    global List<peer.BTransaction> getTrasactions(String fileContent){
        List<peer.BTransaction> retVal = new List<peer.BTransaction>();
        peer.BTransaction bTxn;
        List<String> oneTxn = new List<String>();
        String referenceNumber, bankAccountNumber;
        Decimal amount;
        DateTime transactionDatetime;
        String header = '';
        String targetBankAccountNumber = '';
        Integer year1 = 0,month1= 0,day1= 0;
        Date statementDate;
        String particulars = '';
        String completeBankAccountNumber = '';
        //System.debug(fileContent);
        String[] stackOfLines = fileContent.split('[\n\r]');
        Integer noOfLines = 0;
        
        for(String str : stackOfLines) {
            noOfLines += 1;
            System.debug(noOfLines + ': ' + str);
        }
        //System.debug(stackOfLines[noOfLines]);
        //while(stackOfLines[noOfLines]){
            /*oneTxn = stackOfLines[noOfLines].split(',');
            System.debug('line values are::' + oneTxn);*/
       // }
        return retVal;
    }
}