@isTest
public class WebServiceMockWSSnail implements WebServiceMock {
   public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

            system.debug('stub:::::::::::'+stub);
            system.debug('request:::::::::::'+request);
            if(request instanceof SessionService.GetBindings_element){
              system.debug('instanceof true getBinding');
              new WebServiceMockGetBinding().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
            }
            else if(request instanceof SessionService.Login_element){
              new WebServiceMockLogin().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
            }             

        // Create response element from the autogenerated class.
        // Populate response element.
        // Add response element to the response parameter, as follows:
        //response.put('response_x', responseElement); 
   }
}