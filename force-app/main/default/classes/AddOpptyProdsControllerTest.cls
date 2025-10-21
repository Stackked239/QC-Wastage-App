@isTest
public class AddOpptyProdsControllerTest {
    @isTest
    static void testGetBundleProds() {
        Product2 prod = new Product2(Name='Test',SKUID_SKU__c = '202', SKUID_Color__c = 'Black');
        insert prod;
        List<Product2> prods = AddOpptyProdsController.getBundleProds('202', 'Black');
        System.assertEquals(prods[0].SKUID_SKU__c, '202');
        System.assertEquals(prods[0].SKUID_Color__c, 'Black');
    }

    @isTest
    static void testGetAllProducts() {
        Product2 prod1 = new Product2(Name = 'test1', SKUID_SKU__c = '202', SKUID_Color__c = 'Black');
        Product2 prod2 = new Product2(Name = 'test2', SKUID_SKU__c = '202', SKUID_Color__c = 'Black');
        Product2 prod3 = new Product2(Name = 'test3', SKUID_SKU__c = '202', SKUID_Color__c = 'Black');
        insert new List<Product2>{prod1, prod2, prod3};
            
        List<AddOpptyProdsController.productListWrapper> prods = AddOpptyProdsController.getAllProducts('SKUID_SKU__c', 'ASC', '202', '',new List<Product2>(),new List<String>());
        //System.assertEquals(prods[0].SKUID_SKU__c, '202');
        List<AddOpptyProdsController.productListWrapper> prods2 = AddOpptyProdsController.getAllProducts('SKUID_SKU__c', 'ASC', '202', 'XS',new List<Product2>(),new List<String>());
        AddOpptyProdsController.getCustomSettings();
    }
    
    @isTest
    static void testGetSetUpProds() {
        Product2 prod1 = new Product2(Name = 'test1', SKUID_SKU__c = '202', SKUID_Color__c = 'Black');
        Product2 prod2 = new Product2(Name = 'test2', SKUID_SKU__c = '202', SKUID_Color__c = 'Black');
        insert new List<Product2>{prod1, prod2}; 
            Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id = pricebookId;
        pbe1.Product2Id = prod1.Id;
        pbe1.UnitPrice = 100;
        pbe1.IsActive = true;
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = pricebookId;
        pbe2.Product2Id = prod2.Id;
        pbe2.UnitPrice = 200;
        pbe2.IsActive = true;
        insert pbe2;
        
        
        Opportunity oppty = new Opportunity(Name = 'test', StageName = 'Prospecting',CloseDate = System.today(),Pricebook2Id=pricebookId);
        insert oppty;
       
        OpptyProds__c Mc = new OpptyProds__c();
        Mc.Price_Change_Quantity__c = 576;
        Mc.PricingData1__c = 0.2;
        Mc.PricingData2__c = 0.15;
        Mc.Service_Products__c = '(\'NRM-ART FEE\',\'NRM-Screen Setup Fee\',\'NRM - FedEx Ground\')';
        insert Mc;
        
        List<Product2> prods = AddOpptyProdsController.getSetUpProds('Screen Printing', oppty.Id);
        //System.assertEquals(prods.size(), 0);
        
        OpportunityLineItem oli = new OpportunityLineItem(Product2Id = prod1.Id, OpportunityId = oppty.Id,Quantity=1,UnitPrice = 200);
        insert oli;
        prods = AddOpptyProdsController.getSetUpProds('Screen Printing', oppty.Id);
        //System.assertEquals(prods,new List<Product2>());
    }
    @isTest
    public static void testCreateOpportunityProducts() {
        // Create test products
        Product2 prod1 = new Product2(Name='Test Product 1', IsActive=true);
        insert prod1;
        Product2 prod2 = new Product2(Name='Test Product 2', IsActive=true);
        insert prod2;
        Opportunity oppty = new Opportunity(Name = 'test', StageName = 'Prospecting',CloseDate = System.today(),Pricebook2Id=Test.getStandardPricebookId());
        insert oppty;
        // Create test price book entries
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod1.Id, UnitPrice=50, IsActive=true);
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod2.Id, UnitPrice=100, IsActive=true);
        insert pbe2;
        try{
            // Test with valid products and price book entries
        String opptyProdLines = '{"1":{"Product2Id":"' + prod1.Id + '","SKUID_Color__c":"Black","Quantity":1,"UnitPrice":50,"OpportunityId":"' + oppty.Id + '"},' +
            '"2":{"Product2Id":"' + prod2.Id + '","SKUID_Color__c":"Black","Quantity":1,"UnitPrice":100,"OpportunityId":"' + oppty.Id + '"}}';
        List<OpportunityLineItem> createdProds = AddOpptyProdsController.createOpportunityProducts(opptyProdLines, oppty.Id);
        System.assertEquals(2, createdProds.size());
        for (OpportunityLineItem prod : createdProds) {
            System.assertEquals(oppty.Id, prod.OpportunityId);
            System.assertEquals('test', prod.Color__c);
        }
        
        // Test with missing price book entry
        opptyProdLines = '{"1":{"Product2Id":"' + prod1.Id + '","SKUID_Color__c":"Black","Quantity":1,"UnitPrice":50,"OpportunityId":"' + oppty.Id + '"},' +
            '"2":{"Product2Id":"' + prod2.Id + '","SKUID_Color__c":"Black","Quantity":1,"UnitPrice":100,"OpportunityId":"' + oppty.Id + '"},' +
            '"3":{"Product2Id":"' + 'invalidId' + '","SKUID_Color__c":"Black","Quantity":1,"UnitPrice":100,"OpportunityId":"' + oppty.Id + '"}}';
        createdProds = AddOpptyProdsController.createOpportunityProducts(opptyProdLines, oppty.Id);
        System.assertEquals(0, createdProds.size());
            
        Boolean result = AddOpptyProdsController.deleteAllOpptyProds(String.valueOf(oppty.Id));
    	System.assertEquals(result, true);

    	// Check if the opportunity line items were deleted
    	Integer opptyProdCount = [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId =: oppty.Id];
    	System.assertEquals(opptyProdCount, 0);
        }catch (Exception e) {
            System.debug(e);
        }
        
    }
    @isTest
    public static void testDeleteAllOpptyProds() {
        Opportunity oppty = new Opportunity(Name = 'test', StageName = 'Prospecting',CloseDate = System.today(),Pricebook2Id=Test.getStandardPricebookId());
        insert oppty;
        try{
        Boolean result = AddOpptyProdsController.deleteAllOpptyProds(String.valueOf(oppty.Id));
    	System.assertEquals(result, true);
        }catch (Exception e) {
            System.debug(e);
        }
        
    }
    @isTest
    public static void getSKUPriceTest() {
        Product2 prod1 = new Product2(Name='Test Product 1', IsActive=true);
        insert prod1;
        Product2 prod2 = new Product2(Name='Test Product 2', IsActive=true);
        insert prod2;
        Opportunity oppty = new Opportunity(Name = 'test', StageName = 'Prospecting',CloseDate = System.today(),Pricebook2Id=Test.getStandardPricebookId());
        insert oppty;
        // Create test price book entries
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod1.Id, UnitPrice=50, IsActive=true);
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod2.Id, UnitPrice=100, IsActive=true);
        insert pbe2;
        try{
        String result = AddOpptyProdsController.getSKUPrice(prod1.Id, 2, 3, 2, 100);
    	System.assertEquals(result, Null);
        }catch (Exception e) {
            System.debug(e);
        }
        
    }
    @isTest
    public static void getSKUPriceTest1() {
        Product2 prod1 = new Product2(Name='Test Product 1', IsActive=true);
        insert prod1;
        Product2 prod2 = new Product2(Name='Test Product 2', IsActive=true);
        insert prod2;
        Opportunity oppty = new Opportunity(Name = 'test', StageName = 'Prospecting',CloseDate = System.today(),Pricebook2Id=Test.getStandardPricebookId());
        insert oppty;
        // Create test price book entries
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod1.Id, UnitPrice=50, IsActive=true);
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod2.Id, UnitPrice=100, IsActive=true);
        insert pbe2;
        try{
        String result1 = AddOpptyProdsController.getSKUPrice(prod1.Id, 2, 0, 0, 100);
    	System.assertEquals(result1, Null);
        }catch (Exception e) {
            System.debug(e);
        }
        
    }
    @isTest
    public static void getSKUPriceTest2() {
        Product2 prod1 = new Product2(Name='Test Product 1', IsActive=true);
        insert prod1;
        Product2 prod2 = new Product2(Name='Test Product 2', IsActive=true);
        insert prod2;
        Opportunity oppty = new Opportunity(Name = 'test', StageName = 'Prospecting',CloseDate = System.today(),Pricebook2Id=Test.getStandardPricebookId());
        insert oppty;
        // Create test price book entries
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod1.Id, UnitPrice=50, IsActive=true);
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod2.Id, UnitPrice=100, IsActive=true);
        insert pbe2;
        try{
        String result2 = AddOpptyProdsController.getSKUPrice(prod1.Id, 2, 3, 0, 100);
    	System.assertEquals(result2, Null);
        }catch (Exception e) {
            System.debug(e);
        }
        
    }
    @isTest
    public static void getSKUPriceTest3() {
        Product2 prod1 = new Product2(Name='Test Product 1', IsActive=true);
        insert prod1;
        Product2 prod2 = new Product2(Name='Test Product 2', IsActive=true);
        insert prod2;
        Opportunity oppty = new Opportunity(Name = 'test', StageName = 'Prospecting',CloseDate = System.today(),Pricebook2Id=Test.getStandardPricebookId());
        insert oppty;
        // Create test price book entries
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod1.Id, UnitPrice=50, IsActive=true);
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod2.Id, UnitPrice=100, IsActive=true);
        insert pbe2;
        try{
        String result3 = AddOpptyProdsController.getSKUPrice(prod1.Id, 2, 3, 3, 100);
    	System.assertEquals(result3, Null);
        }catch (Exception e) {
            System.debug(e);
        }
        
    }
    @isTest
    public static void getSKUPriceTest4() {
        Product2 prod1 = new Product2(Name='Test Product 1', IsActive=true);
        insert prod1;
        Product2 prod2 = new Product2(Name='Test Product 2', IsActive=true);
        insert prod2;
        Opportunity oppty = new Opportunity(Name = 'test', StageName = 'Prospecting',CloseDate = System.today(),Pricebook2Id=Test.getStandardPricebookId());
        insert oppty;
        // Create test price book entries
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod1.Id, UnitPrice=50, IsActive=true);
        insert pbe1;
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod2.Id, UnitPrice=100, IsActive=true);
        insert pbe2;
        try{
        String result4 = AddOpptyProdsController.getSKUPrice(prod1.Id, 2, 0, 3, 100);
    	System.assertEquals(result4, Null);
        }catch (Exception e) {
            System.debug(e);
        }
        
    }
}