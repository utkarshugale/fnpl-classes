public with sharing class DataCashUtil {
    public class PaymentRequest {
        public String cardNumber;
        public String expiryDate;
        public String startDate;
        public String username;
        public String password;
        public String amount;
        public String reference;
        public String method;
        
        public PaymentRequest(){
            method = 'pre';
        }
    }
    
    public String paymentXmlGenerator(PaymentRequest reqPackage) {
        String mRef = (reqPackage.reference == null ) ? generateRandomString(9) : reqPackage.reference;
    
        XmlStreamWriter writer = new XmlStreamWriter();
        
        writer.writeStartDocument('utf-8', '1.0');        
        writer.writeStartElement('', 'Request', '2');
        
            writer.writeStartElement(null, 'Authentication', null);
            
                writer.writeStartElement(null, 'client', null);
                    writer.writeCharacters(reqPackage.username);
                writer.writeEndElement();
                
                writer.writeStartElement(null, 'password',null);
                    writer.writeCharacters(reqPackage.password);
                writer.writeEndElement();
            
            writer.writeEndElement();
            
            writer.writeStartElement(null,'Transaction',null);
                writer.writeStartElement(null,'CardTxn',null);
                    writer.writeStartElement(null,'Card',null);
                    
                        writer.writeStartElement(null, 'pan',null);
                        writer.writeCharacters(reqPackage.cardNumber);
                        writer.writeEndElement();
                        
                        writer.writeStartElement(null, 'expirydate',null);
                        writer.writeCharacters(reqPackage.expiryDate);
                        writer.writeEndElement();
                        
                        /*[Optional] no need now.
                        writer.writeStartElement(null, 'startdate',null);
                        writer.writeCharacters(reqPackage.startDate);
                        writer.writeEndElement();*/
            
                    writer.writeEndElement();
                    
                    writer.writeStartElement(null, 'method',null);
                    writer.writeCharacters(reqPackage.method);
                    writer.writeEndElement();
                    
                writer.writeEndElement();
                    
                writer.writeStartElement(null, 'TxnDetails', null);
                    writer.writeStartElement(null, 'merchantreference',null);
                    writer.writeCharacters(mref);
                    writer.writeEndElement();
                    
                    writer.writeStartElement(null, 'amount',null);
                    writer.writeAttribute(null,null,'currency','GBP');
                    writer.writeCharacters(reqPackage.amount);
                    writer.writeEndElement();
                writer.writeEndElement();
                    
            writer.writeEndElement();
            writer.writeEndElement();
            
            String retVal = writer.getXmlString();
            
            writer.close();
            
        return retVal;
    }
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}