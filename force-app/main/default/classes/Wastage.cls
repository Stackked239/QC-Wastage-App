/*
* 27 Sept 2024 UMESH RANA
* Description : This class is called from LWC "WastageLwc". We are getting Sales Order and related Sales Order Item record in the component and
* creating QC_Wastage__c record from the user input. 
*/
public without sharing class Wastage {
    
    @AuraEnabled(cacheable=true)
    public static String getSalesOrderId(String oppId) {
        return [
            SELECT Id
            FROM AcctSeedERP__Sales_Order__c
            WHERE AcctSeedERP__Opportunity__c =: oppId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ].Id;
    }  
    
    @AuraEnabled(cacheable=true)
    public static AcctSeedERP__Sales_Order__c getSalesOrderRecord(String recordId) {
        return [
            SELECT Id, AcctSeedERP__Opportunity__r.Name, Press_Number__c, Printer__c, Unloader__c, Catcher__c, Job_Approved_By__c
            FROM AcctSeedERP__Sales_Order__c
            WHERE Id =: recordId
            LIMIT 1
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AcctSeedERP__Sales_Order_Line__c> getSalesOrderItemRecord(String salesOrderId) {
        return [
            SELECT Id, Product_Name_2__c, AcctSeedERP__Product__r.SKUID_SKU__c, AcctSeedERP__Product__r.SKUID_Color__c, 
            AcctSeedERP__Product__r.SKUID_Size__c, AcctSeedERP__Quantity_Ordered__c
            FROM AcctSeedERP__Sales_Order_Line__c
            WHERE AcctSeedERP__Sales_Order__c =: salesOrderId AND AcctSeedERP__Product__r.Family NOT IN ('Shipping','Service')
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, String>> getSalesOrderPicklist(){
        Map<String, Map<String, String>> picklistValuesMap = new Map<String, Map<String, String>>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('AcctSeedERP__Sales_Order__c');
        Schema.DescribeSObjectResult objDescribe = sObjectType.getDescribe();
        List<String> fieldList = new List<String>{'Press_Number__c','Printer__c', 'Unloader__c', 'Catcher__c', 'Job_Approved_By__c'};
            
            // Iterate over the fields
            for (String fieldName : fieldList) {
                Schema.SObjectField field = objDescribe.fields.getMap().get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                
                // Check if the field is a picklist
                if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                    Map<String, String> fieldPicklistValues = new Map<String, String>();
                    
                    // Get picklist values
                    List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                    for (Schema.PicklistEntry entry : picklistEntries) {
                        fieldPicklistValues.put(entry.getLabel(), entry.getValue());
                    }
                    
                    // Add to the outer map
                    picklistValuesMap.put(fieldName, fieldPicklistValues);
                }
            }
        
        return picklistValuesMap;
    }
    
    @AuraEnabled
    public static void insertWastageRecords(WastageWrapper wastageRecSalesItemList) {
        system.debug(wastageRecSalesItemList);
        List<QC_Wastage__c> insertQCWastage = New List<QC_Wastage__c>();
        for(salesOrderItemWrapper obj : wastageRecSalesItemList.salesOrderItems){
            QC_Wastage__c qcWastage = New QC_Wastage__c();
            qcWastage.of_shirts__c = obj.quantityNeeded;
            qcWastage.Responsible_Party__c = obj.responsibleParty;
            qcWastage.Location__c = obj.location;
            qcWastage.Avoidable__c  = obj.avoidable == true ? 'Yes' : 'No';
            qcWastage.Issue_Group__c = obj.issueGroup;
            qcWastage.Issue_Description__c = obj.issueDescription;
            qcWastage.Job__c = String.isNotBlank(wastageRecSalesItemList.oppName) ? wastageRecSalesItemList.oppName.split('-')[0] : '';
            qcWastage.Name  = DateTime.now().format('MM/dd/yyyy');
            qcWastage.Inventory_SKU__c = obj.productSKU;
            qcWastage.Inventory_colors__c = (obj.color != null && obj.color != 'H. Black') ? obj.color.replace('H. ', '') : obj.color;
            qcWastage.Good_Type__c  = 'Inventory';
            if ( obj.productSKU != null && obj.productSKU.contains('Y') ){
                qcWastage.Inventory_youth_sizes__c = obj.productSize;
            }else{
                qcWastage.Inventory_adult_sizes__c = obj.productSize; 
            }
            if( obj.issueGroup == 'Understaged' ){
                qcWastage.Pulled_from_Inventory__c = true;
            }
            qcWastage.Sales_Order_Line__c  = obj.Id;
            qcWastage.Press_Number__c = wastageRecSalesItemList.pressNumber;
            qcWastage.Job_Approved_By__c = wastageRecSalesItemList.jobApprovedBy;
            qcWastage.Loader__c = wastageRecSalesItemList.printer;
            qcWastage.Unloader__c = wastageRecSalesItemList.unloader;
            qcWastage.Catcher__c = wastageRecSalesItemList.catcher;
            insertQCWastage.add(qcWastage);
        }
        if(insertQCWastage.size() > 0){
            try {
                insert insertQCWastage;  
            } catch(DmlException e) {
                throw new AuraHandledException('Something went wrong: ' + e.getMessage());
            } 
        }
    }
    
    public class WastageWrapper {
        @AuraEnabled public String pressNumber { get; set; }
        @AuraEnabled public String printer { get; set; }
        @AuraEnabled public String unloader { get; set; }
        @AuraEnabled public String catcher { get; set; }
        @AuraEnabled public String jobApprovedBy { get; set; }
        @AuraEnabled public String oppName { get; set; }
        @AuraEnabled public List<SalesOrderItemWrapper> salesOrderItems { get; set; }
    }
    
    public class SalesOrderItemWrapper {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String productSKU { get; set; }
        @AuraEnabled
        public String productName { get; set; }
        @AuraEnabled
        public String color { get; set; }
        @AuraEnabled
        public Integer quantityNeeded { get; set; }
        @AuraEnabled
        public Integer index { get; set; }
        @AuraEnabled
        public String responsibleParty { get; set; }
        @AuraEnabled
        public String issueGroup { get; set; }
        @AuraEnabled
        public String location { get; set; }
        @AuraEnabled
        public String issueDescription { get; set; }
        @AuraEnabled
        public Boolean avoidable { get; set; }
        @AuraEnabled
        public String productSize { get; set; }
        
        
    }
}