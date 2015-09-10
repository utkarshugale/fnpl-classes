@isTest
public class Test_WSFNPLCases {
 
  static contact objContact(){
     Contact objCon = new Contact(LastName='TestContact',Email='test@test.com');
     return objCon;
  }
  
  static testMethod void testGet() {

        //do request
        Contact objCon = Test_WSFNPLCases.objContact();
        insert objCon;
        
        Case objCase = new Case();
        objCase.contactId = objCon.id;
        objCase.status    = 'Inprogress';
        objCase.subject   = 'Test Subject';
        objCase.Description = 'TestDescription';
        insert objCase ;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Cases';  
        req.addParameter('Cid', objCon .id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        test.startTest();
        ResponseCase results = WSFNPLCases.getCases();
        test.stopTest();
    }
    
    static testMethod void testGet1() {
        Case objCase = new Case();
        objCase.status    = 'Closed';
        objCase.subject   = 'Test Subject';
        objCase.Description = 'TestDescription';
        insert objCase ;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Cases';  
        req.addParameter('Cid',null);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        test.startTest();
        ResponseCase results = WSFNPLCases.getCases();
        test.stopTest();
    }
    
    static testMethod void testPost() {
        Contact objCon = Test_WSFNPLCases.objContact();
        insert objCon;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createCase';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        WSFNPLCases.createCase('TestData','TestDescription',objCon.id); 
    }
    
    static testMethod void testPost1() {
        Contact objCon = Test_WSFNPLCases.objContact();
        insert objCon;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createCase';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        WSFNPLCases.createCase('','TestDescription',objCon.id); 
    }
    static testMethod void testPost2() {
        Contact objCon = Test_WSFNPLCases.objContact();
        insert objCon;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createCase';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        WSFNPLCases.createCase('TestData','',objCon.id); 
    }
     static testMethod void testPost3() {
        Contact objCon = Test_WSFNPLCases.objContact();
        insert objCon;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createCase';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        WSFNPLCases.createCase('TestData','TestData',null); 
    }
}