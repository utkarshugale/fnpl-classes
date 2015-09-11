public class webservicetest{
    public static void sendreq(){
        string endpoint =URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/v1/borrowerStatement*';
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(endpoint );
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(12000);
        Date dte = date.today();
          
        request.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        Map<String,object> reqBodyMap = new Map<String,object>();
        reqBodyMap.put('ContractId', 'a3L250000008PBk');
        reqBodyMap.put('borrowerId', '123445');

        reqBodyMap.put('FromDate','14/04/2014');
        reqBodyMap.put('Todate',date.today());
         string reqbody = JSON.serialize(reqBodyMap);
        request.setBody(reqbody);
        HTTPResponse response = new HTTPResponse();
        response  = http.send(request); 
        system.debug('response'+response );  
        system.debug('responsebody'+response.getBody());
        
    }
}