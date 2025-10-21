public class allocateAllSOLIController {
    
    @AuraEnabled
    public static String createSalesOrderLineInventory(String soId){
        String retString;
        try{
            List<AcctSeedERP__Sales_Order_Line__c> salesOrderLineList = new List<AcctSeedERP__Sales_Order_Line__c>();


            
            salesOrderLineList = [SELECT Id, Product_Name_2__c, AcctSeedERP__Product__c ,AcctSeedERP__GL_Account_Variable_1__c,AcctSeedERP__GL_Account_Variable_2__c,Color__c,
                                  Opportunity_Quantity__c, AcctSeedERP__Quantity_Ordered__c,AcctSeedERP__Quantity_Needed__c,AcctSeedERP__Product__r.AcctSeedERP__Sales_Order_Exclude__c,Inventory_Issue__c
                                  FROM AcctSeedERP__Sales_Order_Line__c 
                                  WHERE AcctSeedERP__Sales_Order__c =: soId and 
                                  AcctSeedERP__Product__r.AcctSeedERP__Sales_Order_Exclude__c =: false];
            
            AcctSeedERP__Sales_Order__c currentSalesOrder = [SELECT Id, AcctSeedERP__Ledger__c FROM AcctSeedERP__Sales_Order__c WHERE Id=: soId];
            
            Map<String,AcctSeedERP__Sales_Order_Inventory_Movement__c> soIntvetoryMovementMap = new Map<String,AcctSeedERP__Sales_Order_Inventory_Movement__c>();
            Map<String,Decimal> soliMap = new Map<String,Decimal>();
            Map<String,AcctSeedERP__Sales_Order_Inventory_Movement__c> soIntvetoryMovementFilterMap = new Map<String,AcctSeedERP__Sales_Order_Inventory_Movement__c>();
            
            
            for(AcctSeedERP__Sales_Order_Line__c solObj : salesOrderLineList){
                if(solObj.AcctSeedERP__Quantity_Needed__c !=  0){
                    system.debug('solObj'+solObj);
                    AcctSeedERP__Sales_Order_Inventory_Movement__c inventry = New AcctSeedERP__Sales_Order_Inventory_Movement__c();
                    inventry.AcctSeedERP__Quantity__c = solObj.AcctSeedERP__Quantity_Needed__c;
                    inventry.AcctSeedERP__Movement_Date__c = date.today();
                    inventry.AcctSeedERP__Ledger__c = currentSalesOrder.AcctSeedERP__Ledger__c;
                    inventry.AcctSeedERP__Sales_Order_Line__c = solObj.Id	;
                    inventry.AcctSeedERP__GL_Account_Variable_1__c = solObj.AcctSeedERP__GL_Account_Variable_1__c;
                    inventry.AcctSeedERP__GL_Account_Variable_2__c = solObj.AcctSeedERP__GL_Account_Variable_2__c;
                    
                    soIntvetoryMovementMap.put(solObj.AcctSeedERP__Product__c,inventry);
                    soliMap.put(solObj.AcctSeedERP__Product__c,solObj.AcctSeedERP__Quantity_Needed__c); 
                    
                }
            }
            system.debug('soliMap'+soliMap); system.debug('soliMapsize'+soliMap.values().size());
            system.debug('soIntvetoryMovementMap'+soIntvetoryMovementMap);system.debug('soIntvetoryMovementMap'+soIntvetoryMovementMap.values().size());
            /* List<AcctSeedERP__Location__c> locationObj = [SELECT Id ,Name, AcctSeedERP__Warehouse__c FROM AcctSeedERP__Location__c WHERE 
(Name='B. Finished Goods' OR Name ='Front Door')
AND (AcctSeedERP__Warehouse__r.Name = 'Warehouse 1 - Receiving' 
OR AcctSeedERP__Warehouse__r.Name = 'Warehouse 2 - Receiving')];*/
            
            List<AcctSeedERP__Inventory_Balance__c> listOfInventoryBalance = [SELECT Id,AcctSeedERP__Product__c,AcctSeedERP__Location__r.Name,AcctSeedERP__Warehouse__r.Name,
                                                                              AcctSeedERP__Warehouse__c,AcctSeedERP__Available_Quantity__c,AcctSeedERP__Product__r.Name
                                                                              FROM AcctSeedERP__Inventory_Balance__c 
                                                                              WHERE //AcctSeedERP__Location__c IN: locationObj AND
                                                                              AcctSeedERP__Product__c IN: soIntvetoryMovementMap.keySet()
                                                                             ];
            system.debug('listOfInventoryBalance'+listOfInventoryBalance);
            system.debug('listOfInventoryBalancesize'+listOfInventoryBalance.size());

            List<AcctSeedERP__Sales_Order_Line__c> linesToUpdate = new List<AcctSeedERP__Sales_Order_Line__c>();
            Set<Id> processedIds = new Set<Id>();
            
            for(AcctSeedERP__Inventory_Balance__c invBalObj : listOfInventoryBalance ){
                

                
                if((soliMap.containsKey(invBalObj.AcctSeedERP__Product__c) && invBalObj.AcctSeedERP__Available_Quantity__c >= soliMap.get(invBalObj.AcctSeedERP__Product__c))){
                    if(invBalObj.AcctSeedERP__Location__r.Name == '1B. Finished Goods' && invBalObj.AcctSeedERP__Warehouse__r.Name == 'Warehouse 1 - Receiving'){
                        AcctSeedERP__Sales_Order_Inventory_Movement__c inventory = soIntvetoryMovementMap.get(invBalObj.AcctSeedERP__Product__c);
                        inventory.AcctSeedERP__Inventory_Balance__c = invBalObj.Id;
                        soIntvetoryMovementFilterMap.put(invBalObj.AcctSeedERP__Product__c,inventory);
                    }
                else if(invBalObj.AcctSeedERP__Product__r.Name.startsWith('[FD]') && invBalObj.AcctSeedERP__Location__r.Name == '1A. Front Door Goods' && invBalObj.AcctSeedERP__Warehouse__r.Name == 'Warehouse 1 - Receiving'){
                    AcctSeedERP__Sales_Order_Inventory_Movement__c inventory = soIntvetoryMovementMap.get(invBalObj.AcctSeedERP__Product__c);
                    inventory.AcctSeedERP__Inventory_Balance__c = invBalObj.Id;
                    soIntvetoryMovementFilterMap.put(invBalObj.AcctSeedERP__Product__c,inventory);
                } 
                }
                if(soliMap.containsKey(invBalObj.AcctSeedERP__Product__c )) {
                    Decimal availableQuantity = invBalObj.AcctSeedERP__Available_Quantity__c;
                    Decimal neededQuantity = soliMap.get(invBalObj.AcctSeedERP__Product__c);
                    

                    if(availableQuantity < neededQuantity && invBalObj.AcctSeedERP__Location__r.Name == '1B. Finished Goods' && invBalObj.AcctSeedERP__Warehouse__r.Name == 'Warehouse 1 - Receiving') {
                        Id lineToUpdateId = soIntvetoryMovementMap.get(invBalObj.AcctSeedERP__Product__c).AcctSeedERP__Sales_Order_Line__c;
                
                        if (!processedIds.contains(lineToUpdateId)) {
                            AcctSeedERP__Sales_Order_Line__c lineToUpdate = new AcctSeedERP__Sales_Order_Line__c(Id = lineToUpdateId);
                            lineToUpdate.Inventory_Issue__c = 'WH1 Alert';
                            linesToUpdate.add(lineToUpdate);
                            processedIds.add(lineToUpdateId);
                        }
                    }
            
                }
            }
      
            if( soIntvetoryMovementFilterMap.values().size() > 0 ){
                Insert soIntvetoryMovementFilterMap.values();
            }
            system.debug(' salesOrderLineList.size()'+ salesOrderLineList.size());
            system.debug(' soIntvetoryMovementFilterMap.values().size()'+ soIntvetoryMovementFilterMap.values().size());
            if(soIntvetoryMovementFilterMap.values().size() < salesOrderLineList.size()){
                retString = 'NO AVAILABLE INVENTORY';
            
            }
            else if(soIntvetoryMovementFilterMap.values().size() == salesOrderLineList.size()){
                retString = 'All Sales order line Items allocated successfully!!';
            }
            if(!linesToUpdate.isEmpty()) {
                update linesToUpdate;
            }
        }catch(Exception exp ){
            retString = String.valueOf(exp.getMessage());
        } 
        return retString;
    }
}