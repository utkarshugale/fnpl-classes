@RestResource(urlMapping='/getContractDoc/*')
global with sharing class WebServiceGetContractDoc{

    global class Response{
        public String status;
        public String docId;
        public String pdfBody;
        public String errorCode;
        public String errorMessage;
        
        public Response() {
            errorCode = 'NO_ERROR';
            docId = null;
            pdfBody = null;
            status = null;
           
        }
    }
    
    class Request{
        public String contractId;
        public String templateId;
    }
    
    @HttpPost
    global static Response doPost(){
        RestRequest req = RestContext.request;
        Response res = new Response();
        String jsondata = req.requestBody.toString();
        String templateName = '';
        System.debug('JSON String for getting eSign: ' + jsondata);
        Request auth;
        try{
            auth = (Request)JSON.deserialize(jsondata, Request.class);
        }catch (Exception e){
           res.status = e.getMessage();
           res.errorCode = 'INVALID_INPUT_FORMAT:';
           return res;
        }
        System.debug(auth);
        if(String.isEmpty(auth.ContractId)){
            res.errorCode = 'INVALID_INPUT_FORMAT';
            res.status = 'ERROR';
            res.errorMessage = 'ContractId can not be null';
            return res;
        }
        if(String.isEmpty(auth.TemplateID)){
            res.errorCode = 'INVALID_INPUT_FORMAT';
            res.status = 'ERROR';
            res.errorMessage = 'Template name can not be null';
            return res;
        }
        DDP_Parameters__c ddpParams = DDP_Parameters__c.getInstance();
        if(auth.templateId.equalsIgnoreCase(ddpParams.Credit_Agreement_DDP_Id__c)){
            templateName = ddpParams.Credit_Agreement_Template_Name__c;
            
        }else if(auth.templateId.equalsIgnoreCase(ddpParams.Pre_Contract_Credit_Info_DDP_Id__c)){
            templateName = ddpParams.Pre_Contract_Credit_Info_Template_Name__c;
        }
        
        try{
            loan__Loan_Account__c loanContract = [select Id ,Name from loan__Loan_Account__c where Id=:auth.contractId limit 1];
            System.debug('loan Contract: '+loanContract);
            String query = 'select Id ,Body from Attachment where ParentId=\''+loanContract.Id+'\' and Name=\''+templateName+'.pdf\' order by SystemModstamp desc ';
            System.debug('Query: '+query);
            List<Attachment> attach=Database.query(query);
            res.status='SUCCESS';
            res.docId=attach[0].Id;
            
            res.pdfBody=EncodingUtil.base64Encode(attach[0].Body);
            
            System.debug('Encoded String:---'+res.pdfBody);
            res.errorCode='NO ERROR';
            
            //Decoding For tesing and storing in CL Contract.
          /*  Attachment decodedAttach = new Attachment();    
            decodedAttach.Name='Decoded '+templateName;
            Blob bodyBlob = EncodingUtil.base64Decode(res.pdfBody);
            String decodedString = EncodingUtil.base64Encode(bodyBlob);
            
            System.debug(res.pdfBody + 'is now decoded as: ' + decodedString );
            decodedAttach.body= bodyBlob;
            
            decodedAttach.parentId = auth.ContractId;
            decodedAttach.ContentType='application/pdf';
            insert decodedAttach; */
        }catch(Exception e){
            res.status=e.getMessage();
            res.errorCode='ERROR';
            
            return res;
        }
        return res;
        
    }

}