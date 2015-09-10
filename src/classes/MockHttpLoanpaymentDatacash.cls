global class MockHttpLoanpaymentDatacash implements HttpCalloutMock{
    //This is to send fake response to loanpaymenttransaction sweep to datacash apex class

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        string xmlresponse = '<?xml version="1.0" encoding="UTF-8"?> <Response> <datacash_reference>4200204417079300</datacash_reference> <information>The card number contains non-numeric characters</information> <merchantreference>dG24r0MQD</merchantreference> <mode>TEST</mode> <reason>ACCEPTED</reason> <status>25</status> <time>1441867814</time> </Response>';
        res.setBody(xmlresponse);
        res.setHeader('Content-Type', 'application/JSON');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}