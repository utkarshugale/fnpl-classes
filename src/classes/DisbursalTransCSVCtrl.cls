/*
 * Author             :	Rahul Sangwan
 * Created Date       :	2 Sept. 2015
 * Last Modified By   :	Rahul Sangwan
 * Last Modified Date : 3 Sept. 2015
 * 
 * Purpose: Create a CSV file of Loan Disbursal Transaction records of last month and save it in Document folder.
 */
public class DisbursalTransCSVCtrl {
    List<FNPL_SFC_Insurance_Pricing__c> fnpl;
    Map<Decimal, FNPL_SFC_Insurance_Pricing__c> fnplMap;
    List<Decimal> fnplKeyList;
    List<loan__Loan_Disbursal_Transaction__c> disbursalList;
    Document csvDoc;
    
    //Purpose: Initialize all the objects and get the loan disbursal List of Last Month and set the FNPL file in Map and 
    //Level of Sum Insured upto(Column in FNPL file) in List and sort it.
    public DisbursalTransCSVCtrl(){
        csvDoc        = new Document();
        fnpl          = new List<FNPL_SFC_Insurance_Pricing__c>();
        fnplMap       = new Map<Decimal, FNPL_SFC_Insurance_Pricing__c>();
        fnplKeyList   = new List<Decimal>();
        disbursalList = new List<loan__Loan_Disbursal_Transaction__c>();
        
        //Get the start date of previous month to use that in query.
        Date lastMonthStartDate = Date.today().addMonths(-1).toStartOfMonth();
        //get number of days in month to add them in start date to get the end date.
        Integer days 			= date.daysInMonth(lastMonthStartDate.year(),lastMonthStartDate.month());
        //get the end date of previous month to use that in query.
        Date lastMonthEndDate 	= lastMonthStartDate.addDays(days - 1);
        
        //get the Loan Disbursal Transaction of last month based on loan disbursal date.
        try{
        disbursalList = [Select Id, loan__Disbursal_Date__c,
                         loan__Disbursed_Amt__c,
                         loan__Loan_Account__r.loan__Contact__r.Name
                         from loan__Loan_Disbursal_Transaction__c
                         where loan__Disbursal_Date__c >=: lastMonthStartDate 
                         AND loan__Disbursal_Date__c <=: lastMonthEndDate];
        }catch(Exception e){
            system.debug('Exception::::::::::'+e.getMessage());
        }
        
        //get all the values of FNPL SFC file from custom settings.
        fnpl          = FNPL_SFC_Insurance_Pricing__c.getall().values();
        
        //Prepare a map of FNPL where key is Level of Sum Insured upto and Value as whole FNPL object.
        //Prepare a list of Level of Sum Insured values(needed to sort the values of Level of Sum insured which is not possible with map)
        for(FNPL_SFC_Insurance_Pricing__c fnplObj : fnpl){
            fnplMap.put(fnplObj.Level_of_Sum_Insured_up_to__c , fnplObj);
            fnplKeyList.add(fnplObj.Level_of_Sum_Insured_up_to__c);
        }
        try{
        fnplKeyList.sort();
        }catch(Exception e){
            system.debug('Exception:::::::'+e.getMessage());
        }
        //system.debug('...........'+fnplKeyList);
    } 
    
    //Purpose: Create CSV file and save it in Document in particular folder.
    public void createCSV(){
        Id folderId;
        
        //get the folder where CSV file will be stored.
        try{
        folderId = [Select Id, Name from Folder where Name = 'Insurance Reports'].Id;
        }catch(Exception e){
            system.debug('Exception:::::::::'+e.getMessage());
        }
        
        //set the header of CSV
        String header   = ' S.No, Clients Name , Transaction creation date, Transaction Amount, Up to Sum Insured, Premium to MGA, IPT, Total due to MGA (Premium plus IPT) \n';
        String finalStr = header;
        
        //used to set the S.No. in CSV
        Integer i = 1;
        
        //traverse the loan disbursal List and fnplKeyList and find the range in which particular loan disbursal resides.
        //if it falls in particular range find all the values(uptoSumInsured, premiumToMGA, ipt, totalDue) and add it in string so that Row will be created in CSV.
        //if no range found the all values(uptoSumInsured, premiumToMGA, ipt, totalDue) will be 0.
        for(loan__Loan_Disbursal_Transaction__c disbursalObj : disbursalList){
            Decimal uptoSumInsured = 0;
            Decimal premiumToMGA   = 0;
            Decimal ipt            = 0;
            Decimal totalDue       = 0;
            
            for(Decimal key : fnplKeyList){
                if(disbursalObj.loan__Disbursed_Amt__c <= key){
                    if(fnplMap.containsKey(key)){
                    	if(fnplMap.get(key).Level_of_Sum_Insured_up_to__c != null)
	                    uptoSumInsured = fnplMap.get(key).Level_of_Sum_Insured_up_to__c;
    					if(fnplMap.get(key).Gross_Premium_Per_Transaction__c != null)
                        premiumToMGA   = fnplMap.get(key).Gross_Premium_Per_Transaction__c;
                    	if(fnplMap.get(key).IPT__c != null)
                        ipt            = fnplMap.get(key).IPT__c;
                        if(fnplMap.get(key).Total_Premium__c != null)
	                    totalDue       = fnplMap.get(key).Total_Premium__c;
                    }
                    break;
                }
            }
            
            //create the row and add it to CSV String
            String row = '"'+i+'","'+
                         disbursalObj.loan__Loan_Account__r.loan__Contact__r.Name+'","'+
                         disbursalObj.loan__Disbursal_Date__c+'","'+
                         disbursalObj.loan__Disbursed_Amt__c+'","'+
                         uptoSumInsured+'","'+
                         premiumToMGA+'","'+
                         ipt+'","'+
                         totalDue+'"\n';            
            finalStr   = finalStr + row;            
            i++;
        }
        
        csvDoc.Name        = String.valueOf(Date.today())+'.csv';
        csvDoc.Body        = Blob.valueOf(finalStr);
        csvDoc.ContentType = 'csv';
        if(folderId != null)
        csvDoc.FolderId    = folderId;
        try{
        	insert csvDoc;
        }catch(Exception e){
            system.debug('Exception:::::::::::'+e.getMessage());
        }
        //system.debug('::::::::::::::'+csvDoc.Id);
    }
}