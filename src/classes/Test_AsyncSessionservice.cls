@isTest
private class Test_AsyncSessionservice {
    
    @isTest static void test_method_AsyncSessionservice1() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.IsPermissionGrantedResponse_elementFuture isPermissionObj = new AsyncSessionservice.IsPermissionGrantedResponse_elementFuture();
        isPermissionObj.getValue();
        
        }Catch(Exception e){}
    }
        @isTest static void test_method_AsyncSessionservice2() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.GetServiceInformationResponse_elementFuture ServiceInfo = new AsyncSessionservice.GetServiceInformationResponse_elementFuture();
        ServiceInfo.getValue();
        
        }Catch(Exception e){}
    }
        @isTest static void test_method_AsyncSessionservice3() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());

        AsyncSessionservice.LogoutResponse_elementFuture logoutResponce = new AsyncSessionservice.LogoutResponse_elementFuture();
        logoutResponce.getValue();
        
        }Catch(Exception e){}
    }
        @isTest static void test_method_AsyncSessionservice4() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.GetSessionInformationResponse_elementFuture sessionInfo = new AsyncSessionservice.GetSessionInformationResponse_elementFuture();
        sessionInfo.getValue();
        
        }Catch(Exception e){}
    }
        @isTest static void test_method_AsyncSessionservice5() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.GetOtherUserDisplayNameResponse_elementFuture otherDis = new AsyncSessionservice.GetOtherUserDisplayNameResponse_elementFuture();
        otherDis.getValue();
        
        }Catch(Exception e){}
    }
        @isTest static void test_method_AsyncSessionservice6() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.LoginResponse_elementFuture logRes = new AsyncSessionservice.LoginResponse_elementFuture();
        logRes.getValue();
        
        }Catch(Exception e){}
    }
        @isTest static void test_method_AsyncSessionservice7() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.GetBindingsResponse_elementFuture bindRes= new AsyncSessionservice.GetBindingsResponse_elementFuture();
        bindRes.getValue();
        
        }Catch(Exception e){}
    }
        @isTest static void test_method_AsyncSessionservice8() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.AsyncSessionServiceSoap sync = new AsyncSessionservice.AsyncSessionServiceSoap(); 
        sync.beginIsPermissionGranted(null,'test','testdata');
        
        }Catch(Exception e){}
    }
            @isTest static void test_method_AsyncSessionservice9() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.AsyncSessionServiceSoap sync = new AsyncSessionservice.AsyncSessionServiceSoap(); 
        sync.beginGetServiceInformation(null,'test');
        
        }Catch(Exception e){}
    }  
            @isTest static void test_method_AsyncSessionservice10() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.IsPermissionGrantedResponse_elementFuture isPermissionObj = new AsyncSessionservice.IsPermissionGrantedResponse_elementFuture();
        AsyncSessionservice.AsyncSessionServiceSoap sync = new AsyncSessionservice.AsyncSessionServiceSoap(); 
        sync.beginGetOtherUserDisplayName(null,'testLogin','testaddress');
        
        }Catch(Exception e){}
    }  
            @isTest static void test_method_AsyncSessionservice11() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSessionservice.AsyncSessionServiceSoap sync = new AsyncSessionservice.AsyncSessionServiceSoap(); 
        sync.beginLogin(null,'testUsername','testPassword');
        
        }Catch(Exception e){}
    }  
            @isTest static void test_method_AsyncSessionservice12() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());       
        AsyncSessionservice.AsyncSessionServiceSoap sync = new AsyncSessionservice.AsyncSessionServiceSoap(); 
        sync.beginGetBindings(null,'testData');
        
        }Catch(Exception e){}
    } 
                @isTest static void test_method_AsyncSessionservice13() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());       
        AsyncSessionservice.AsyncSessionServiceSoap sync = new AsyncSessionservice.AsyncSessionServiceSoap(); 
        sync.beginLogout(null);
        
        }Catch(Exception e){}
    }
                @isTest static void test_method_AsyncSessionservice14() {
        // Implement test code
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());       
        AsyncSessionservice.AsyncSessionServiceSoap sync = new AsyncSessionservice.AsyncSessionServiceSoap(); 
        sync.beginGetSessionInformation(null);
        
        }Catch(Exception e){}
    }     
}