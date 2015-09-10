//Wrapper class to assign Praser Data.

  global class RefundTransactionParser{
    
    public list<ParserFile> lstParserFile;
    public string strFileName{get;set;}
    public Blob fileParser{get;set;}
    
    global RefundTransactionParser(){
     lstParserFile = new list<ParserFile>();
    }
    
   global class ParserFile{
     public string strNumber;
     public string strDate;
     public string strAccount;
     public string strAmount;
     public string strSubcategory;
     public string strMemo;
     
     //Wrapper constructor.
     global ParserFile() {
        strNumber = '';
        strDate = '';
        strAccount = '';
        strAmount  = '';
        strSubcategory = '';
        strMemo = '';
        
     }
   }
   
   //File Upload Method and also assign parser format values to wrapper list.
   public void fileUploadParser(){
     //Converting to Blob to String.
     list<string> filelines  = new list<string>();
     strFileName = fileParser.toString();
     //Split Headers.
     filelines = strFileName.split('\n');
     
     for(Integer i = 1; i < filelines.size(); i++) {
        
         String[] strcolvalues = new String[] {};
         //Split each Column
         strcolvalues = filelines[i].split(',');
         strcolvalues[5] = strcolvalues[5].replaceAll('(\\s+)', ' ');
         list<string> lstMemoColumns = strcolvalues[5].split(' ');
         //Wrapper to assign data.
         ParserFile objPaserObj      = new ParserFile();
         objPaserObj.strNumber       = strcolvalues[0];
         objPaserObj.strDate         = strcolvalues[1];
         objPaserObj.strAccount      = strcolvalues[2];
         objPaserObj.strAmount       = strcolvalues[3];
         objPaserObj.strSubcategory  = strcolvalues[4];
         objPaserObj.strMemo         = lstMemoColumns[2];
         lstParserFile.add(objPaserObj);
      }
      
      system.debug('*****lstParserFile*****'+lstParserFile);
   }
   
  }