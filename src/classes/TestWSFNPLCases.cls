@isTest
public class TestWSFNPLCases {
    private static Contact c;
    private static loan__Loan_Account__c loanAccount;
    
    @testSetup static void createSeedData() {
        System.debug(LoggingLevel.eRROR,' running test data ');
        loan.TestHelper.createSeedDataForTesting();
        
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        
        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount ,dummyAccount); 
        dummyFee.loan__Time_OF_Charge__c = 'Esker';
        update dummyFee;
                                           
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
        
        c = new Contact(LastName = 'Test');
        c.Email = 'utkarsh@cloudlendinginc.com';
        c.MailingCity = 'RYE';
        c.MailingStreet = '22 Tower Street';
        c.MailingState = 'East Sussex';
        c.MailingCountry = 'GB';
        c.MailingPostalCode = 'TN31 7AT';
        insert c;
        
        //Create a dummy Loan Account
        loanAccount = loan.TestHelper.createLoanAccountForContactObj(dummyLP,
                                                    c,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        
    }
    
    static testMethod void testGetcase() {
    
        loanAccount = [Select Id,Name from loan__Loan_Account__C limit 1];

        RestRequest req         = new RestRequest(); 
        RestResponse res        = new RestResponse();
        req.requestURI          = '/services/apexrest/v1/cases';  
        req.addParameter('Cid', '00325000003i29qs');
        req.httpMethod          = 'GET';
        RestContext.request     = req;
        RestContext.response    = res;
        case caseobj= new case();
        case[] caseobjq         = null;
            contact conobj      = new contact();
            conobj.LastName     ='Test';
            conobj.Email        ='Test@Flynowpaylater.com';
            insert conobj;
            caseobj.Subject     ='Test Subject';
            caseobj.Description ='Test Description';
            caseobj.ContactId   ='00325000003i29q';//conobj.Id;
            insert  caseobj;
            system.debug('caseobj'+caseobj);
                caseobjq=[select Subject,Description,status from case where contact.id=:caseobj.ContactId ];
                string casenum      ='100';
                ResponseCase results=new ResponseCase ();
                results.openCase('message', 'status', 'Errmessage', 'Errcode', caseobjq);
                results.noOpenCase('message',' status',' Errmessage',' Errcode');
                results.noValidEmail('message', 'status', 'Errmessage', 'Errcode');
                results.postCaseError('message', 'status', 'Errmessage', 'Errcode');
                results.postCaseBlankInputError('message', 'status', 'Errmessage', 'Errcode');
                results.postCaseSuccess('message', 'status', 'Errmessage', 'Errcode', casenum);
                ResponseCase r = WSFNPLCases.getCases();
          
                //HTTP POST Method Invoke        
                RestRequest req1            = new RestRequest(); 
                RestResponse res1           = new RestResponse();
                req.requestURI              = '/services/apexrest/v1/cases';  
                req.httpMethod              = 'POST';
                RestContext.request         = req1;
                RestContext.response        = res1;

                Contact conoobj             = new contact(Lastname='test',email='k@gmail.com');
                list <contact> con          =new list<contact>();
                con.add(conoobj);
                insert conoobj;
                system.debug('conoobj'+conoobj);
                system.debug('ccon'+con);
                
                case casepost               =new case();
                casepost.Subject            = 'Subject' ;
                casepost.Description        = 'Description' ;
                casepost.ContactId          = conoobj.id;
                casepost.Origin             ='Web';
                casepost.Status             ='Open';
                insert casepost;
                System.assert(con.size()!=0);
         
                ResponseCase rr=WSFNPLCases.createCase('', '', conobj.id,'');
                ResponseCase rr1=WSFNPLCases.createCase('', 'Description',conobj.id,'');
                ResponseCase rr3=WSFNPLCases.createCase('Subject', '',conobj.id,'');
                ResponseCase rr4=WSFNPLCases.createCase('Subject', 'Description', conobj.id,'');
                ResponseCase rr5=WSFNPLCases.createCase('Subject', 'Description', conobj.id,loanAccount.Id);
              
    }

}