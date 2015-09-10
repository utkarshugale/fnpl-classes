public class WebToCaseController {
    public PageReference PageReferences;
    Public String casenum {get;  set;}
    Public String checkLA{ get; set;}
    list<Loan__Loan_Account__c > listLoanAcc=new list<Loan__Loan_Account__c >();
    Public Case caseobj{ get; set;} 
    
    public String contactEmail{get;set;}
    
    public WebToCaseController(){
         caseobj = new case();
         
         contactEmail = ApexPages.currentPage().getParameters().get('email');
         
    }
     
    Public PageReference Create_case(){  
        
        List<String> lst = new List<String>();
        
        
        
        listLoanAcc=[SELECT Loan__contact__r.lastname ,Loan__contact__r.firstname ,Loan__contact__r.email,Loan__contact__r.Name , 
                     name FROM Loan__Loan_Account__c where name =: checkLA];
                 
        system.debug('contact list'+listLoanAcc );
        
        if(listLoanAcc.size()==1){
            try{
                case casecreate=new case();
                Loan__Loan_Account__c con = listLoanAcc.get(0);
                 
                lst.add(con.Loan__contact__r.email);
                lst.add(contactEmail); 
                 
                casecreate.Subject=caseobj.Subject;
                casecreate.Description=caseobj.Description;
                casecreate.ContactId=con.Loan__Contact__c;
                System.debug('caseobj.Subject'+caseobj.Subject);
                System.debug('caseobj.Description'+caseobj.Description);
                System.debug('caseobj.Loan__Contact__c'+con.Loan__Contact__c);
                
                casecreate.Origin='Web';
                casecreate.Status='New';
                
                // Specify DML options to ensure the assignment rules are executed
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                casecreate.setOptions(dmlOpts);
                insert casecreate;
            
                
                // Thankyou page assigning on casenumber
                Case cFromDB=[select id, CaseNumber from Case where id=:casecreate.id];               
                casenum = cFromDB.CaseNumber;
                System.debug('casenum casenum' +casenum);
                     
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'success');
                ApexPages.addMessage(msg);
                
                //Sending a Acknowledgement to that particular mail-id related to Loan contract -contact id.
        
                  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject( caseobj.subject );
                    email.setToAddresses(lst);
                    email.setSenderDisplayName('Support@Travelfund.com');
                    email.setPlainTextBody(
                    'Dear  ' +con.Loan__contact__r.Name+ '\n\n'+
                    'Thank you for your interest!  Your case Number is  '+ casenum+'\n\n'   
                        + 'And Your case Subject : '+ caseobj.Subject+'\n\n'+
                        'Your case Description  : '+ caseobj.Description+'\n\n'

                  );
                    
                // Sends the email
                    Messaging.SendEmailResult [] r = 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
                
            }
           
            catch (system.NullPointerException e) {
                
                System.debug('System.NullPointerException e   ' +e);
              //  case cc=new case();
                caseobj.adderror('There is a problem while Creating a case'); 
            }
     
       return new PageReference('/apex/Web_To_Case_ThankYou');
       
       }
       
        else{
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Loan Contract ID Does not match ');
            ApexPages.addMessage(msg);
             
        }
        
        return null; 
    }
}