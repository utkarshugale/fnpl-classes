@isTest
public class Test_AsyncSubmissionservice {
    @isTest
    private static void AsyncSubmissionserviceTestMethod2(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.DownloadFileResponse_elementFuture down = new AsyncSubmissionservice.DownloadFileResponse_elementFuture();
        down.getValue();
        }Catch(Exception e){}
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod3(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.ListResourcesResponse_elementFuture listRes = new AsyncSubmissionservice.ListResourcesResponse_elementFuture();
        listRes.getValue();
        }Catch(Exception e){}
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod4(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.SubmitXMLResponse_elementFuture subXML = new AsyncSubmissionservice.SubmitXMLResponse_elementFuture();
        subXML.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod5(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.RegisterResourceResponse_elementFuture regRes = new AsyncSubmissionservice.RegisterResourceResponse_elementFuture();
        regRes.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod6(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.DeleteResourceResponse_elementFuture delRes = new AsyncSubmissionservice.DeleteResourceResponse_elementFuture();
        delRes.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod7(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.UploadFileAppendResponse_elementFuture upFile = new AsyncSubmissionservice.UploadFileAppendResponse_elementFuture();
        upFile.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod8(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.ConvertFileResponse_elementFuture conFile = new AsyncSubmissionservice.ConvertFileResponse_elementFuture();
        conFile.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod9(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.SubmitTransportResponse_elementFuture subTran = new AsyncSubmissionservice.SubmitTransportResponse_elementFuture();
        subTran.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod10(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.ExtractNextResponse_elementFuture extNext = new AsyncSubmissionservice.ExtractNextResponse_elementFuture();
        extNext.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod11(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.RetrieveResourceResponse_elementFuture retRes = new AsyncSubmissionservice.RetrieveResourceResponse_elementFuture();
        retRes.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod12(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.ExtractFirstResponse_elementFuture extFirst = new AsyncSubmissionservice.ExtractFirstResponse_elementFuture();
        extFirst.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod13(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.UploadFileResponse_elementFuture upFileRes = new AsyncSubmissionservice.UploadFileResponse_elementFuture();
        upFileRes.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionserviceTestMethod14(){
        try{
        Test.setMock(WebServiceMock.class, new AsyncSessionserviceisPermMock());
        AsyncSubmissionservice.SubmitResponse_elementFuture subRes = new AsyncSubmissionservice.SubmitResponse_elementFuture();
        subRes.getValue();
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod1(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginDownloadFile(null,null);       
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod2(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginListResources(null,'TestType',True);       
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod3(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginSubmitXML(null,null);      
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod4(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginRegisterResource(null,null,'TextX',True,True);     
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod5(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginDeleteResource(null,'Test','testdata',True);       
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod6(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginUploadFileAppend(null,'fileContent',null);     
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod7(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginConvertFile(null,null,null);       
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod8(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginSubmitTransport(null,null);        
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod9(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginExtractNext(null,null);        
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod10(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginRetrieveResource(null,'test','type_x',True,'eMode');       
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod11(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginDownloadFile(null,null);       
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod12(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginExtractFirst(null,null,null,null);     
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod13(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginUploadFile(null,'fileContent','name');     
        }Catch(Exception e){}   
    }
    @isTest
    private static void AsyncSubmissionServiceSoapTestMethod14(){
        try{
        AsyncSubmissionservice.AsyncSubmissionServiceSoap subSoap = new AsyncSubmissionservice.AsyncSubmissionServiceSoap();
        subSoap.beginSubmit(null,'subject',null,null);      
        }Catch(Exception e){}   
    }   
}