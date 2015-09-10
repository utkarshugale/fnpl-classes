global virtual class Response {
    
    global String status {get; set;}
    global String errorCode {get; set;}
    // Added variable errorMessage to store 
    // multi-lingual message 
    global String errorMessage {get; set;}
   
    global List<SObject> content {get;set;}
    global List<peer.CustomResponse> response{get;set;}
    global Integer errorNumber {get;set;}
    global Integer rowNumber {get;set;}
    
    global Response() {
        status = null;
        errorCode = peer.Constants.NO_ERROR;
        errorMessage = null;
        content = new List<SObject>();
        response = new List<peer.CustomResponse>();
    }

}