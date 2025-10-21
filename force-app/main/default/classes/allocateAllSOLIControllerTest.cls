@isTest
public class allocateAllSOLIControllerTest {
    @testsetup
    public static void init(){   
        
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        AcctSeed__Billing_Format__c billformat = new AcctSeed__Billing_Format__c();
        billformat.Name = 'test pdf';
        billformat.AcctSeed__Type__c = 'Billing';
        billformat.AcctSeed__Visualforce_PDF_Page__c = 'QuotePdf';
        billformat.AcctSeed__Default_Email_Template__c = 'SUPPORTSelfServiceResetPasswordSAMPLE2';
        insert billformat;
        
        AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
        glAccount.Name= 'test';
        glAccount.AcctSeed__Type__c ='Balance Sheet';
        glAccount.AcctSeed__Sub_Type_1__c = 'Assets';
        glAccount.AcctSeed__Sub_Type_2__c = 'Cash';
        glAccount.AcctSeed__Bank__c = true;
        insert glAccount;
        
        AcctSeed__Ledger__c ledgertest = new AcctSeed__Ledger__c();
        ledgertest.Name = 'test ledger';
        ledgertest.AcctSeed__Type__c = 'Transactional';
        ledgertest.AcctSeed__Default_Bank_Account__c = glAccount.Id;
        ledgertest.AcctSeed__Billing_Activity_Statement_Format__c =  billformat.Id;
        ledgertest.AcctSeed__Billing_Outstanding_Statement_Format__c = billformat.Id;
        ledgertest.AcctSeed__Default_Billing_Format__c = billformat.Id;
        ledgertest.AcctSeed__Default_Purchase_Order_Format__c = billformat.Id;
        ledgertest.AcctSeed__Default_Packing_Slip_Format__c = billformat.Id;
        insert ledgertest;
        
        AcctSeedERP__Sales_Order__c salesOrder = new AcctSeedERP__Sales_Order__c();
        salesOrder.AcctSeedERP__Customer__c = acc.Id;
        salesOrder.AcctSeedERP__Status__c = 'open';
        salesOrder.AcctSeedERP__Ledger__c = ledgertest.Id;
        insert salesOrder;
        
        Product2 prod = new Product2(Name = '[FD] Test',
                                     Family = 'Hardware',
                                     AcctSeed__Inventory_Product__c = true,
                                     AcctSeed__Expense_GL_Account__c = glAccount.id,
                                     AcctSeed__Inventory_GL_Account__c = glAccount.Id,
                                     AcctSeed__Inventory_Type__c = 'Purchased',
                                     AcctSeedERP__Sales_Order_Exclude__c = false,
                                     AcctSeed__Revenue_GL_Account__c = glAccount.Id);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        AcctSeedERP__Sales_Order_Line__c sorderLineItem = new AcctSeedERP__Sales_Order_Line__c();
        sorderLineItem.AcctSeedERP__Product__c = prod.Id;
        sorderLineItem.AcctSeedERP__Quantity_Ordered__c = 0.1;
        sorderLineItem.AcctSeedERP__Sales_Order__c = salesOrder.Id;
        insert sorderLineItem;
        
        AcctSeedERP__Warehouse__c warehouse = new AcctSeedERP__Warehouse__c();
        warehouse.Name = 'Warehouse 1 - Receiving';
        insert warehouse;
        
        AcctSeedERP__Location__c locationObj = new AcctSeedERP__Location__c();
        locationObj.Name = '1B. Finished Goods';
        locationObj.AcctSeedERP__Warehouse__c = warehouse.id;
        insert locationObj;
        
        AcctSeedERP__Inventory_Balance__c inventoryBalance = new AcctSeedERP__Inventory_Balance__c();
        inventoryBalance.AcctSeedERP__Product__c = prod.id;
        inventoryBalance.AcctSeedERP__Location__c = locationObj.Id;
        inventoryBalance.AcctSeedERP__Warehouse__c = warehouse.Id;
        insert inventoryBalance;
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.Name = '2022-03';
        ap.AcctSeed__Start_Date__c = Date.today();
        ap.AcctSeed__End_Date__c = Date.today() + 100;
        insert ap;
        
        AcctSeedERP__Inbound_Inventory_Movement__c iim = new AcctSeedERP__Inbound_Inventory_Movement__c();
        iim.AcctSeedERP__Quantity__c = 10;
        iim.AcctSeedERP__Type__c = 'Accounting';
        iim.AcctSeedERP__Movement_Date__c = Date.today();
        iim.AcctSeedERP__Inventory_Balance__c = inventoryBalance.id;
        iim.AcctSeedERP__Unit_Cost__c = 12;
        iim.AcctSeedERP__Ledger__c = ledgertest.id;
        iim.AcctSeedERP__Credit_GL_Account__c = glAccount.id;
        
        insert iim;
        
        
        
    }
    
    @isTest
    public static void testAllSOLIController(){
        
        Id salesOrderId = [SELECT ID FROM AcctSeedERP__Sales_Order__c Limit 1].Id;
        AcctSeedERP__Sales_Order_Line__c sol = [SELECT Id, Name, AcctSeedERP__Quantity_Needed__c, AcctSeedERP__Quantity_Allocated__c FROM AcctSeedERP__Sales_Order_Line__c];
       	AcctSeedERP__Inventory_Balance__c ib = [SELECT Id, Name, AcctSeedERP__Available_Quantity__c FROM AcctSeedERP__Inventory_Balance__c];
        
        Test.startTest();
        allocateAllSOLIController.createSalesOrderLineInventory(salesOrderId);
        Test.stopTest();
    }
    
    @isTest
    public static void testAllSOLIController1(){
        
        Id salesOrderId = [SELECT ID FROM AcctSeedERP__Sales_Order__c Limit 1].Id;
        
        AcctSeedERP__Location__c loc = [SELECT id, Name FROM AcctSeedERP__Location__c Limit 1];
        loc.Name = '1A. Front Door Goods';
        update loc;
        
        AcctSeedERP__Warehouse__c ware = [SELECT id, Name FROM AcctSeedERP__Warehouse__c Limit 1];
        ware.Name = 'Warehouse 1 - Receiving';
        update ware;
        
        AcctSeedERP__Inventory_Balance__c ibal = [SELECT id, AcctSeedERP__Warehouse__r.Name, AcctSeedERP__Location__r.Name FROM AcctSeedERP__Inventory_Balance__c Limit 1];
        ibal.AcctSeedERP__Location__c = loc.Id;
        ibal.AcctSeedERP__Warehouse__c = ware.id;
        update ibal;
        
        Test.startTest();
        allocateAllSOLIController.createSalesOrderLineInventory(salesOrderId);
        Test.stopTest();
    }
}