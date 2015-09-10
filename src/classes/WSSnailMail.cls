public class WSSnailMail {
    private static SubmissionService.Var CreateValue(String AttributeName, String AttributeValue) {
      SubmissionService.Var varNew = new SubmissionService.Var();
      varNew.Attribute = AttributeName;
      varNew.SimpleValue = AttributeValue;
      varNew.Type_x = 'TYPE_STRING';
      return varNew;
    }
    
    private String getAddress(Contact con){
        return con.MailingStreet + '\r\n'+
               con.MailingCity+'\r\n'+
               con.MailingState+ '\r\n'+ 
               con.MailingPostalCode+'\r\n'+
               con.MailingCountry;
    }
    
    public String sendMail(Blob fileContent, Contact customer, String fileName) {       
        Blob b = fileContent;
        System.debug('Blob is' + b);
        
        SessionService.SessionServiceSoap session = new SessionService.SessionServiceSoap();
        sessionservice.BindingResult bindings = session.GetBindings('jasperdykes@flynowpaylater.com');
        
        System.debug(LoggingLevel.ERROR,' Binding '+bindings);
        
        session.endpoint_x = bindings.sessionServiceLocation;
        
        System.debug(LoggingLevel.ERROR,'Endpoint '+session.endpoint_x);
        
        //Login to Esker.
        sessionService.LoginResult login = session.Login('jasperdykes@flynowpaylater.com', 'Toffee28');
        
        submissionservice.SubmissionServiceSoap submission = new submissionservice.SubmissionServiceSoap();
        submission.endpoint_x = bindings.submissionServiceLocation;
        
        System.debug('Endpoint::' + submission.endpoint_x);
        System.debug('session Id::' + login.sessionId);
        
        //Get Session Header.
        submission.SessionHeaderValue = new submissionService.SessionHeader();
        submission.SessionHeaderValue.sessionId = login.sessionId;
       
        submissionService.Transport transport = new submissionService.Transport();
        transport.TransportName = 'MODEsker';
        
        SubmissionService.Var[] vars = new SubmissionService.Var[8];
        vars[0] = CreateValue('Subject', 'Sample Mail On D');
        vars[1] = CreateValue('FromName', 'Markus Rafferty');
        Vars[2] = CreateValue('FromCompany', 'Cosmic Torment');
        vars[4] = CreateValue('ToBlockAddress', getAddress(customer));
        vars[5] = CreateValue('Color', 'Y');
        vars[6] = CreateValue('Cover', 'Y');
        vars[7] = CreateValue('BothSided', 'N');
        
        SubmissionService.vars_element varsTransport = new SubmissionService.vars_element();
        varsTransport.var = vars;
        //transport.Vars = new submissionservice.vars_element();
        transport.vars = varsTransport;
        
        
        SubmissionService.WSFile docToSend = new SubmissionService.WSFile();
        docToSend.name = fileName;
        docToSend.mode = 'MODE_INLINED';
        docToSend.content = EncodingUtil.base64Encode(b);
        System.debug('doc to send::' + docToSend);
        
        
        SubmissionService.Attachment[] attachments = new SubmissionService.Attachment[1];
        attachments[0] = new SubmissionService.Attachment();
        attachments[0].SourceAttachment = docToSend;
        attachments[0].InputFormat = '.pdf';
        attachments[0].OutputFormat = '.pdf';
        attachments[0].Stylesheet = '';
        attachments[0].OutputName = fileName;
        
        
        SubmissionService.attachments_element atts = new SubmissionService.attachments_element();
        atts.attachment = attachments;
        //transport.Attachments = new SubmissionService.attachments_element();
        transport.Attachments = atts;
        
        System.debug('transport::' + transport);
        
        //transport.setAttachments(new TransportAttachments(attach));
        
        try {
          SubmissionService.SubmissionResult result = submission.submitTransport(transport);
          return 'Request submitted with transportID ' + result.TransportID;
        } catch (Exception ex) {
          return 'An unexpected error has occurred.' + ex.getMessage();
        }
        return null;
    }
}