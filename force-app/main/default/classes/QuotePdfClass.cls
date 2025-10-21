public class QuotePdfClass {
    public Quote quoteRecord {get;set;}
    public list<QuoteLineItem> quoteLineItems {get;set;}
    public Opportunity oppRecord {get;set;}
    
    public  QuotePdfClass(Apexpages.StandardController std){
        

        
        Quote quoteRec = (Quote)std.getRecord();
        
        if(quoteRec.Id !=null){
            quoteRecord   =  [select id, ExpirationDate, OpportunityId,QuoteNumber,ShippingStreet,ShippingPostalCode,TotalPrice,
                              ShippingCountry,ShippingState,ShippingCity,Customer_Comments__c,ShippingName,
                              CreatedDate, Opportunity.name, Opportunity.Shipping_Street__c, Opportunity.Shipping_Zip__c, Opportunity.Shipping_Country__c, 
                              Opportunity.Shipping_State__c, Opportunity.Shipping_City__c from Quote where id=:quoteRec.Id ];
                         
            //DateTime d = quoteRecord.CreatedDate;
            //quoteRecord.ExpirationDate = d.date().addDays(14);
            
            String dynamicFileName = 'Quote'+' '+quoteRecord.QuoteNumber+'.pdf';
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+dynamicFileName); 
            
            quoteLineItems =  fetchLineItems(quoteRec.Id);
            
            oppRecord = [select id,name, Shipping_Street__c, Shipping_Zip__c, Shipping_Country__c, Shipping_State__c, Shipping_City__c
                         from Opportunity where Id =: quoteRecord.OpportunityId];
        }  
    }
    
    public list<QuoteLineItem> fetchLineItems(Id quoteId ){
        return [Select Id, Product2.Name,Color_Field__c,Product2.Family,Product2.Description,Description, Quantity,UnitPrice,
                TotalPrice, SubTotal from QuoteLineItem where QuoteId =: quoteId order by sortorder asc];
    }
    
    //Below Method is used to save the Pdf in salesforce files
    @AuraEnabled
    public static Wrapper savePdf(String recordId){
        Boolean isSuccess = false;
        List<Quote> quoteRecord = new List<Quote>();
        
        PageReference pdfPage = new PageReference('/apex/QuotePdf');
        pdfPage.getParameters().put('Id', recordId);
        
        Id conDocument;
       
        try{    
            if(String.isNotBlank(recordId)){
                
                quoteRecord = [select id,QuoteNumber,Contact_ID__c,ExpirationDate,CreatedDate from quote where id=:recordId];
                
                ContentVersion cVersion = new ContentVersion();
                cVersion.Title =  'Quote'+' '+quoteRecord[0].QuoteNumber+'.pdf';
                cVersion.PathOnClient = 'Quote.pdf';
                
                if(!Test.isRunningTest()){
                cVersion.VersionData = pdfPage.getContentAsPdf();
                }
                else{
                  cVersion.VersionData = Blob.valueOf('Test');   
                }
                cVersion.Origin = 'H';
                Insert cVersion;
                
              conDocument   = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = recordId;
                cDocLink.ShareType = 'I';
                cDocLink.Visibility = 'AllUsers';
                insert cDocLink;
                
             
                                    
                isSuccess = true;
                
            }
             
        }catch(Exception ex){
            system.debug('exception'+ex);
        }
        
        Wrapper wrappObj = new Wrapper();
        wrappObj.QuoteRecord = quoteRecord.size()>0 ? quoteRecord[0] : null;
        wrappObj.isSuccess = isSuccess;
        wrappObj.contentDocId = conDocument;
        
        return wrappObj;
    }
    
    public class Wrapper{
        @AuraEnabled
        public quote QuoteRecord;
        @AuraEnabled
        public boolean isSuccess;
        @AuraEnabled
        public string contentDocId;
    }
    
    
}