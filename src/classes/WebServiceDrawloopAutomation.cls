@RestResource(urlMapping='/generateDocuments/*')
global with sharing class WebServiceDrawloopAutomation {

    static String  sessionId = UserInfo.getSessionId();
    String deployId;
    String templateId;
    String contractId;
    String ddpId;
    @HttpPost
    global static Response getParams(){
        String deployId;
        String contractId;
        String templateId;
        String ddpId;
        RestRequest req = RestContext.request;
        RestResponse restRes = RestContext.response;
        Response res = new Response();
        System.debug('Req: '+req );
        try {
            RequestBodyParser.RequestBodyParams reqParams = RequestBodyParser.getJsonParamsFromRequest(req);
            Map<String, Object> params = reqParams.getParams();
            system.debug('Params: '+params );
            
          /*  deployId = req.params.get('deployId') != null ? req.params.get('deployId') : null;
            templateId = req.params.get('templateId') != null ? req.params.get('templateId') : null;
            contractId = req.params.get('contractId') != null ? req.params.get('contractId') : null; */
            
          //deployId = (String)params.get('deployId');
            templateId = (String)params.get('templateId');
            contractId = (String)params.get('contractId');
            
            if(String.isEmpty(contractId)){
                res.errorCode = 'INVALID_INPUT_FORMAT';
                res.status = 'ERROR';
                res.errorMessage = 'ContractId can not be null';
                return res;
            }
            if(String.isEmpty(templateId)){
                res.errorCode = 'INVALID_INPUT_FORMAT';
                res.status = 'ERROR';
                res.errorMessage = 'Template Id can not be null';
                return res;
            }
            
            DDP_Parameters__c ddpParams = DDP_Parameters__c.getInstance();
            if(templateId.equalsIgnoreCase(ddpParams.Credit_Agreement_DDP_Id__c)){
                ddpId = ddpParams.Credit_Agreement_DDP_Id__c;
                deployId = ddpParams.Credit_Agreement_Deploy_ID__c;
            }else if(templateId.equalsIgnoreCase(ddpParams.Pre_Contract_Credit_Info_DDP_Id__c)){
                ddpId = ddpParams.Pre_Contract_Credit_Info_DDP_Id__c;
                deployId = ddpParams.Pre_Contract_Credit_Info_Deploy_Id__c;
            }
            
            
            System.debug('Deploy Id: '+deployId);
            System.debug('DDP Id: '+ddpId);
            System.debug('Contract Id: '+contractId);
            if(deployId!=null && ddpId!=null && contractId !=null && sessionId!=null){
                generateDDP(deployId,ddpId,contractId,sessionId ); 
            }
            res.status = 'SUCCESS';
                       
            return res;          
        } catch (Exception e) {
            res.errorCode = peer.Constants.INVALID_INPUT;
            res.status = peer.Constants.ERROR;
            restRes.statuscode = peer.Constants.HTTP_BAD_REQUEST;
            res.errorMessage = 'UNABLE_PARSE_REQ_PARAMS';           
            return res;
        } 
        
        
    }
    
    @future(callout = true)
    public static void generateDDP(String deployId,String templateId,String loanAppId,String sId){
        Map<string, string> variables = new Map<string,string>();
        variables = new Map<string, string> { 'deploy' => deployId };
        Loop.loopMessage lm = new Loop.loopMessage();
        lm.sessionId=sId;
        lm.requests.add(new Loop.loopMessage.loopMessageRequest(loanAppId,templateId,variables));
        lm.sendAllRequests();
    }
  
}