public without sharing class AddOpptyProdsController {

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getBundleProds( string skucode,  string skucolor) {
	    return [SELECT Id, Name,SKUID_SKU__c,SKUID_Color__c,SKUID_Size__c,Sort_Order__c,Description,Size_Percentage__c FROM Product2 where SKUID_SKU__c =: skucode and SKUID_Color__c = : skucolor order by Inventory_Sort_Order__c];        
    }

    @AuraEnabled(cacheable=true)
    public static List<productListWrapper> getAllProducts(string sortBy,string sortDirection,string filter,String searchkey, List<Product2> productList,List<String> selectedProductIds){
        List<productListWrapper> listOfProductsWrapper = new List<productListWrapper>();

        String query = 'SELECT Id,Name,Inventory_Sort_Order__c, SKUID_SKU__c, SKUID_Color__c, SKUID_Size__c,Description,Size_Percentage__c from Product2'
                        +' WHERE Id <> null AND Id NOT IN:productList AND SKUID_SKU__c != NULL AND SKUID_Color__c != NULL ';
        if( filter != null && filter != 'All') {
            query += ' AND SKUID_SKU__c = :filter';
        }
        if ( searchKey != null && searchKey != '' ) {
                String key = '%' + searchKey + '%';
                query += ' AND (Name LIKE :key OR SKUID_SKU__c LIKE :key OR Description LIKE :key)';
        }
        if( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection  + ' NULLS LAST';
        }
        List<Product2> listOfProducts = Database.query( query );
        for(Product2 product: listOfProducts){ 
            if( !selectedProductIds.isEmpty() && selectedProductIds.contains(product.Id)){
                listOfProductsWrapper.add(new productListWrapper(true ,product));
            }else{
                listOfProductsWrapper.add(new productListWrapper(false ,product));
            } 
        }
        return listOfProductsWrapper;
    }
    public class productListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public Product2 product{get;set;}
        public productListWrapper(boolean isChecked, Product2 product){
            this.isChecked = isChecked;
            this.product = product;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getSetUpProds(string setup, Id opptyId) {
        
        OpptyProds__c mc = OpptyProds__c.getOrgDefaults();
        string serviceProds = mc.Service_Products__c;
        string squery1 = 'SELECT Id FROM OpportunityLineItem WHERE Product2.Name IN ' + serviceProds + ' AND OpportunityId =\'' + opptyId + '\'';
        string squery2 = 'SELECT Id, Name FROM Product2 WHERE Name IN ' + serviceProds;
        if(setup == 'Screen Printing'){
            List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
            opptyProds = Database.query(squery1);
	        if(opptyProds.size() > 0){
                return null;
            }
            else{
                return Database.query(squery2);
            }
        }
        else {
            return Database.query(squery2);
        }
    }

    @AuraEnabled
    public static List<OpportunityLineItem> createOpportunityProducts(String opptyProdLines, String opptyId){
        try {

            List<OpportunityLineItem> opptyProdToDelete = new List<OpportunityLineItem>();
            opptyProdToDelete = [SELECT Id FROM OpportunityLineItem where Color__c = 'Quote' AND OpportunityId =: opptyId AND (Opportunity.IsClosed = false OR Opportunity.StageName <> 'Production Schedule/Quote Approval')];
            
            if(opptyProdToDelete.size() > 0){
                delete opptyProdToDelete;
            }

            String sError = '';
            List<OpportunityLineItem> opptyProdToInsert = new List<OpportunityLineItem>();
            Map<String, Object> OpportunityLines = (Map<String, Object>)JSON.deserializeUntyped(opptyProdLines);    // Deserialized map of products to be inserted as opportunity products
            
            Set <Id> ProductIds = new Set<Id>();

            //To verify if the to be created opportunity product has a standard price book entry
            for (String prbe : OpportunityLines.keySet()) { //Find all unique products
                Map<String,Object> opptyProd = (Map<String,Object>)OpportunityLines.get(prbe);
                ProductIds.add(String.valueOf(opptyProd.get('Product2Id')));
            }

            List<PricebookEntry> pbe = [select id, name,Pricebook2Id,Product2Id from PriceBookEntry where Pricebook2.Name = 'Standard Price Book' and Product2Id in: ProductIds];
            
            Map <Id, Id> pbeIds = new Map <Id, Id>();
            for (PricebookEntry prod : pbe) {
                pbeIds.put(prod.Product2Id, prod.Id);
            }
                
            for (String key : OpportunityLines.keySet()) {
                OpportunityLineItem opptyProdRec = new OpportunityLineItem();
                Map<String,Object> oppProd = (Map<String,Object>)OpportunityLines.get(key);

                opptyProdRec.OpportunityId = String.valueOf(oppProd.get('OpportunityId'));
                Id prodId = String.valueOf(oppProd.get('Product2Id'));
                opptyProdRec.Product2Id = prodId;
                opptyProdRec.Color__c = String.valueOf(oppProd.get('SKUID_Color__c'));
                opptyProdRec.Quantity = Integer.valueOf(oppProd.get('Quantity'));
                opptyProdRec.UnitPrice = decimal.valueOf(String.valueOf(oppProd.get('UnitPrice')));
                if(pbeIds.get(prodId) != null){
                    opptyProdRec.PricebookEntryId = pbeIds.get(prodId);
                }
                else{
                    sError = sError + ' ' + prodId;
                }
                opptyProdToInsert.add(opptyProdRec);
            }
            
            if(sError != ''){
                opptyProdToInsert.clear();
                throw new AuraHandledException('Price book entry is mandatory for creating a Opportunity Product. Please create the missing standard pricebook entry for :' + sError);
            }
            else{
                insert opptyProdToInsert;
            }
            return opptyProdToInsert;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getSKUPrice(String prodId, Integer frontColor, Integer backColor, Integer otherColor, Integer totalGarments){
        try {
            
            String query; 
            String sFCField = 'Front_Color_'+frontColor+'__c';
            String sBCField = 'Add_Color_'+backColor+'__c';
            String sOCField = 'Add_Color_'+otherColor+'__c';
            Decimal totalPrice;
            String skuId;
            Decimal MarkupPrice = 0;
         
            if(backColor == 0 && otherColor == 0){
                query = 'SELECT Id,Product__r.SKUID_Size__c, '+sFCField+' FROM SKU_Price__c WHERE Product__c = :prodId AND Min_Pieces__c <= :totalGarments AND Max_Pieces__c >= :totalGarments';
                List<SKU_Price__c> skuPrice = Database.query(query);
                totalPrice = Decimal.valueof(String.valueOf(skuPrice[0].get(sFCField))) + MarkupPrice;
                skuId = String.valueOf(skuPrice[0].Id);
            }    
            else if(backColor > 0 && otherColor == 0){
                query = 'SELECT Id,Product__r.SKUID_Size__c, Front_Color_'+frontColor+'__c, Add_Color_'+backColor+'__c FROM SKU_Price__c WHERE Product__c = :prodId AND Min_Pieces__c <= :totalGarments AND Max_Pieces__c >= :totalGarments';    
                List<SKU_Price__c> skuPrice = Database.query(query);
                totalPrice = Decimal.valueof(String.valueOf(skuPrice[0].get(sFCField))) + Decimal.valueof(String.valueOf(skuPrice[0].get(sBCField))) + MarkupPrice;
                skuId = String.valueOf(skuPrice[0].Id);
            }
            else if(backColor == 0 && otherColor > 0){
                query = 'SELECT Id, Product__r.SKUID_Size__c,Front_Color_'+frontColor+'__c, Add_Color_'+otherColor+'__c FROM SKU_Price__c WHERE Product__c = :prodId AND Min_Pieces__c <= :totalGarments AND Max_Pieces__c >= :totalGarments';    
                List<SKU_Price__c> skuPrice = Database.query(query);
                totalPrice = Decimal.valueof(String.valueOf(skuPrice[0].get(sFCField))) + Decimal.valueof(String.valueOf(skuPrice[0].get(sOCField))) + MarkupPrice;
                skuId = String.valueOf(skuPrice[0].Id);
            }
            else if(backColor > 0 && otherColor > 0){
                if(backColor == otherColor)
                    query = 'SELECT Id, Product__r.SKUID_Size__c,Front_Color_'+frontColor+'__c, Add_Color_'+backColor+'__c FROM SKU_Price__c WHERE Product__c = :prodId AND Min_Pieces__c <= :totalGarments AND Max_Pieces__c >= :totalGarments';
                else
                    query = 'SELECT Id, Product__r.SKUID_Size__c,Front_Color_'+frontColor+'__c, Add_Color_'+backColor+'__c, Add_Color_'+otherColor+'__c FROM SKU_Price__c WHERE Product__c = :prodId AND Min_Pieces__c <= :totalGarments AND Max_Pieces__c >= :totalGarments';
                List<SKU_Price__c> skuPrice = Database.query(query);
                totalPrice = Decimal.valueof(String.valueOf(skuPrice[0].get(sFCField))) + Decimal.valueof(String.valueOf(skuPrice[0].get(sBCField))) + Decimal.valueof(String.valueOf(skuPrice[0].get(sOCField)));
                skuId = String.valueOf(skuPrice[0].Id);
            }
            
            return skuId+','+string.valueof(totalPrice);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean deleteAllOpptyProds(String opptyId){
        try{
            OpportunityLineItem[] opptyProdsToDelete = [SELECT Id, Name FROM OpportunityLineItem WHERE OpportunityId =: opptyId]; 
            delete opptyProdsToDelete;

            return true;
        }catch (Exception e) {throw new AuraHandledException(e.getMessage());}
        }

    // get custom settings to pass to LWC
    @AuraEnabled(cacheable=true) 
    public static OpptyProds__c getCustomSettings(){
        return OpptyProds__c.getOrgDefaults();
    }
}