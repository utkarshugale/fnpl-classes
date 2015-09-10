@RestResource(urlMapping='/v1/cases')
global class WSFNPLCases {

    @HTTPGET
    global static ResponseCase getCases(){
        RestRequest req          = RestContext.request;
        RestResponse res         = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        string Cid = RestContext.request.params.get('Cid');
        
        List<contact> Contactid  = new List<contact>();
        Case[] Caseobj           =null;
        ResponseCase resCase = new ResponseCase();
        
        //[Utk] - Please fetch cases using ContactId. In case, if Cusotmer changes his email, your code will fail.
        //Query all fields on Case requested by FNPL.
        Contactid=[select id from contact where id=:Cid];
        if(Contactid.size() == 0){
           return resCase.noValidEmail('No Customer Account  found for given ID.','Error','ID Not Present in the system','400');

        }
        
        Caseobj=[select casenumber,subject,Description,status,Createddate from case where contact.id=:Contactid AND Status !='Closed' ORDER BY createddate ASC];


        if(Caseobj.size()==0){        
                res.statusCode = 200;
                resCase.noOpenCase('No Active Case',' Success','Null','200');
        }
        else{
                //resCase.openCase(message, status, Errmessage, Errcode, casepara)
                resCase.openCase('Áctive Case', ' Success', 'Null','200', Caseobj);
        }
        
        return resCase;
    }

    @HTTPPOST
    global static ResponseCase createCase(String subject,string description,string Cid,String contractId) {
        RestRequest req             = RestContext.request;
        RestResponse res            = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        ResponseCase resCase        = new ResponseCase();
        
        List<Contact> Listcontact;
        string casenum;
        Case caseobj;
        Contact contactobj;
           
        //String.isEmpty(description) && String.isEmpty(Cid)
        if( String.isEmpty(subject))  {
            res.statusCode = 400;
            return resCase.postCaseBlankInputError('Please Enter Mandatory Fields (Missing Subject)', 'Error', 'Null Value on Subject Field', '400');
            
        }else if( String.isEmpty(description) ) {
            res.statusCode = 400;
            return resCase.postCaseBlankInputError('Please Enter Mandatory Fields (Missing Description)', 'Error', 'Null Value on Description Field', '400');

       }else if(!String.isEmpty(contractId)) {
           List<loan__Loan_Account__c> loanContract = [Select Id,Name,loan__contact__r.Name,loan__Contact__r.Email from loan__Loan_Account__C Where Id =: contractId];
           
           if(loanContract.isEmpty()) {
               res.statusCode = 400;
               return resCase.postCaseBlankInputError('Contract Not found for given contract Id.', 'Error', 'Incorrect Contract Value.', '400');
           }else{
               
               caseObj = getNewCase(subject,description,contactObj,loanContract[0]);
               insert caseObj;
               
                Case cFromDB=[select id, CaseNumber from Case where id=:caseobj.id];               
                casenum = cFromDB.CaseNumber;
                
                //Sending a Acknowledgement to that particular mail-id
                
                String body = 'Hi  \n\n' + loanContract[0].loan__contact__r.Name+
                'Thank you for your interest!  Your case Number is  '+ casenum + '\n\n';
                
                sendEmail(subject,loanContract[0].loan__contact__r.Email,'Support@FNPL.com',body);
               
               return resCase.postCaseSuccess('Case Created Successfully','Success','Null', '200',casenum);
           }
       }else {
        
           listcontact = [select id,name,email from contact where id=: Cid];
           
           if(listcontact.size() != 0 ) {
                contactobj      = listcontact.get(0);
                
                caseObj = getNewCase(subject,description,contactObj,null);
                insert caseobj ;
                
                Case cFromDB=[select id, CaseNumber from Case where id=:caseobj.id];               
                casenum = cFromDB.CaseNumber;
                
                //Sending a Acknowledgement to that particular mail-id
                
                String body = 'Hi  \n\n' +contactobj.Name+
                'Thank you for your interest!  Your case Number is  '+ casenum + '\n\n';
                
                sendEmail(subject,contactobj.Email,'Support@FNPL.com',body);
          
                return resCase.postCaseSuccess('Case Created Successfully','Success','Null', '200',casenum) ;
  
            }else{
                
                res.statusCode = 400;
                return resCase.postCaseError('No Customer Account found for given ID .','Error','ID Does not match in the system', '400');
            
            }
        
        }
        
    }
    
    public static void sendEmail(String subject,String toMail, String fromMail, String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setToAddresses(new String[]{toMail});
        email.setSenderDisplayName(fromMail);
        email.setPlainTextBody(body);
        
        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});         
    }
    
    private static Case getNewCase(String sub,String description, Contact contact, loan__Loan_Account__c contract) {
        Case caseobj = new Case();
        caseobj.Subject         = sub;
        caseobj.Description     = description;
        
        if(Contact != null) {
            caseobj.ContactId       = contact.Id;
        }else {
            caseObj.Contract_ID__c = contract.Id;
        }
        caseobj.Origin          ='Web';
        caseobj.Status          ='Open';
        
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        caseobj.setOptions(dmlOpts);
        
        return caseObj;
    }
}