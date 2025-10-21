public class SalesOrderClass {
    public AcctSeedERP__Sales_Order__c soRecord {get;set;}
    public List<AcctSeedERP__Sales_Order_Line__c> soLine {get;set;}
    
    public  SalesOrderClass(Apexpages.StandardController std){
        
        AcctSeedERP__Sales_Order__c soRec = (AcctSeedERP__Sales_Order__c)std.getRecord();
        
        
      /*  if(soRec.Id !=null){
            soRecord   =  [SELECT Id,Name__c,Name,AcctSeedERP__Opportunity__c,Production_Date__c,AcctSeedERP__Customer__c,Customer_Due_Date__c,
                           Must_Have_Date__c,Monday_Production_ID__c,OPP_of_items__c,OwnerId,AcctSeedERP__Status__c,Staged_By__c,Received_By__c,
                           Product_Order_Type__c,Print_Summary__c,AcctSeedERP__Total__c
                           FROM AcctSeedERP__Sales_Order__c 
                           WHERE id=:soRec.Id ];
        }*/
            
            soLine = [SELECT Id,Opportunity_Quantity__c,AcctSeedERP__Quantity_Allocated__c,AcctSeedERP__Quantity_Ordered__c,
                      AcctSeedERP__Sales_Order__c,AcctSeedERP__Product__r.Name,Color__c,AcctSeedERP__Quantity_Received_Supplier__c  
                      FROM AcctSeedERP__Sales_Order_Line__c 
                      WHERE AcctSeedERP__Sales_Order__c=:soRec.Id
                     ORDER BY Non_Allocatable_Item__c ASC, AcctSeedERP__Product__r.Inventory_Sort_Order__c ASC, Color__c ASC, AcctSeedERP__Product__r.Name ASC];
        
    }
}