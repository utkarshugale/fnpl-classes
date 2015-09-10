public class PaymentTransactionResponse {

    public loan__Loan_Payment_Transaction__c lpt;
    public String errorMessage;
    public List<String> errorMessages;
    public String successMessage;
    public List<String> successMessages;
    public String responseBody;
    
    public PaymentTransactionResponse() {
        errorMEssages = new List<String>();
        errorMessage = '';
        successMessage = '';
        successMessages = new List<String>();
    }
}