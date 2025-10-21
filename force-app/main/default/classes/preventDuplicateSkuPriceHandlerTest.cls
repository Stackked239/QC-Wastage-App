@isTest
public class preventDuplicateSkuPriceHandlerTest {
    @isTest
    static void testDuplicateInsert() {
        Product2 prod1 = new Product2(Name='Test Product 1', IsActive=true);
        insert prod1;
        Pricing_Data__c pricingData = new Pricing_Data__c();
        insert pricingData;
        
        SKU_Price__c newSku = new SKU_Price__c(Product__c=prod1.Id, Pricing_Data__c=pricingData.Id);
        List<SKU_Price__c> newSkus = new List<SKU_Price__c>{newSku};
        insert newsku;
        
        SKU_Price__c duplicateSku = new SKU_Price__c(Product__c=prod1.Id, Pricing_Data__c=pricingData.Id);
        List<SKU_Price__c> duplicateSkus = new List<SKU_Price__c>{duplicateSku};
        
        Test.startTest();
        try{
           preventDuplicateSkuPriceHandler.preventDuplicateInsertOrUpdate(duplicateSkus);
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('A combination of this Product and Pricing Data already exists'), e.getMessage());
            }
        Test.stopTest();
    }
}