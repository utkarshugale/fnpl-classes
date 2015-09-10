@isTest
private class Test_WSSnailMail {
    
    @isTest static void test_method_WSSnailMail() {
        // Implement test code
        Contact dummyClient = new Contact(LastName = 'Test Contact'
        ,MailingStreet='Koramangala',MailingCity='Banglore',MailingState='Karnataka',MailingPostalCode='500082',MailingCountry='India',
        email='jasperdykes@flynowpaylater.com');
        insert dummyClient;
        
        String blobStr = 'test';
        Blob b = Blob.valueOf(blobStr);
        Test.setMock(WebServiceMock.class, new WebServiceMockWSSnail());
        //Test.setMock(SubmissionService.Var.class, new WSSnailMail());
        Test.startTest();
        WSSnailMail wssObj = new WSSnailMail();
        wssObj.sendMail(b,dummyClient,'test');
        Test.stopTest();
    }
    
}