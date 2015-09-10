public with sharing class RunShareGenController {

    public void runBatchJob() {
        
        ShareReportingFileGen gen = new ShareReportingFileGen();
        Database.executeBatch(gen);
    }
    
    public void run(){
        Contact c = [Select Id,Name,
                            FirstName,
                            LastName,
                            MiddleName,
                            Salutation,
                            Suffix
                     From Contact 
                     Where Id = '00325000002Zwhf'];
        
        ShareInsightFormatGen obj = new ShareInsightFormatGen();
        obj.getBorrowerName(c);
        
                    
    }
}