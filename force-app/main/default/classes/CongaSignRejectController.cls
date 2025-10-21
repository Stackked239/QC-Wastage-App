public without sharing class CongaSignRejectController {
    public boolean isChecked {get;set;}  
    public boolean isSuccess {get;set;}
    public boolean isError {get;set;}
    public string errormsg {get;set;}
    
    
    public CongaSignRejectController(){
        isSuccess = false;
        isError = false;
    }
    
    public void saveRejectedFormData(){
        
        system.debug(isChecked);
        
       // Boolean isRejected = Boolean.valueOf(Apexpages.currentPage().getParameters().get('isRejected'));
        string commentsData = system.CurrentPageReference().getParameters().get('commentsInput');
        String  QuoteId = apexpages.currentpage().getparameters().get('Id'); 
        
        Quote quoteobj = new Quote();
        quoteobj.Id = QuoteId;
        quoteobj.Customer_Comments__c = commentsData;
        quoteobj.Customer_Rejected__c = isChecked;
        
        
        try{
            update quoteobj;
            isSuccess = true;
            isError = false;
        }
        catch(Exception ex){
            isSuccess = false;
            isError = true;
            errormsg = ex.getMessage();
        }
       
    }

}