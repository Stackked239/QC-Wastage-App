@isTest
public class Test_SalesOrderClass {

    @isTest
    public static void testSalesOrderClass(){   
        
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
        
        Product2 prod = new Product2(Name = 'Test',
                                     Family = 'Hardware');
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
        sorderLineItem.AcctSeedERP__Quantity_Ordered__c = 10;
        sorderLineItem.AcctSeedERP__Sales_Order__c = salesOrder.Id;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(salesOrder);
        SalesOrderClass testAccPlan = new SalesOrderClass(sc);
        
        PageReference pageRef = Page.QuotePdf;
        pageRef.getParameters().put('Id', String.valueOf(salesOrder.Id));
        Test.setCurrentPage(pageRef);
                
    }
}