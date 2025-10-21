public without sharing class preventDuplicateSkuPriceHandler {
    
    public static void preventDuplicateInsertOrUpdate(List<SKU_Price__c> newSkus) {
        List<Id>    prod     = new List<Id>();
        List<Id> pricingData = new List<Id>();
        
        for(SKU_Price__c newSku : newSkus){
            prod.add(newSku.Product__c);
            pricingData.add(newSku.Pricing_Data__c);
        }
        
        List<SKU_Price__c> existingSKU = [SELECT Id, Product__c, Pricing_Data__c FROM SKU_Price__c WHERE Product__c IN: prod AND Pricing_Data__c IN:pricingData];
        
        if(existingSKU.size()>0){
            existingSKU[0].addError('A combination of this Product and Pricing Data already exists');
        }
    }
}