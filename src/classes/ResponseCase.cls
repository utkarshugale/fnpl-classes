global  class ResponseCase {
    
    Public String Message;
    Public String caseNumber;
    Public String Status;
    Public String ErrMessage;
    Public String Code;
    Public List<case> Caselist=new List<Case>();
    
      
    public  ResponseCase noValidEmail(String message, String status,String Errmessage,String Errcode){
       
            this.Message        =message;
            this.status         =status;
            this.ErrMessage     =Errmessage;
            this.Code           =Errcode;
            this.caseNumber     = null;
            return this;
    }
    
    
    public  ResponseCase noOpenCase(String message, String status,String Errmessage,String Errcode){
           
            this.Message        =message;
            this.status         =status;
            this.ErrMessage     =Errmessage;
            this.Code           =Errcode;
            this.caseNumber     = null;
            return this;
    }
    
    public ResponseCase openCase(String message, String status,String Errmessage,String Errcode,List<Case> casepara){
           
            this.Message        =message;
            this.Status         =status;
            this.ErrMessage     =Errmessage;
            this.Code           =Errcode;
            this.Caselist       =casepara;
            this.caseNumber     = 'Null';
            return this;
    }

     public ResponseCase postCaseError(String message, String status,String Errmessage,String Errcode){
            
            this.Message        =message;
            this.Status         =status;
            this.ErrMessage     =Errmessage;
            this.Code           =Errcode;
            this.caseNumber     = null;
            return this;
    }
    
    public ResponseCase postCaseSuccess(String message, String status,String Errmessage,String Errcode,String casenum){
           
            this.Message        =message;
            this.Status         =status;
            this.ErrMessage     =Errmessage;
            this.Code           =Errcode;
            this.caseNumber     =casenum;
            return this;
    } 
        
    public ResponseCase postCaseBlankInputError(String message, String status,String Errmessage,String Errcode){
            
            this.Message        =message;
            this.Status         =status;
            this.ErrMessage     =Errmessage;
            this.Code           =Errcode;
            this.caseNumber     = null;
            return this;
    }
    
}