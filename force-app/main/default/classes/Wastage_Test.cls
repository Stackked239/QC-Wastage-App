@isTest
public class Wastage_Test {
	
    testMethod static void createdWastageRec(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp',
                                         AccountId = acc.Id,
                                         StageName = 'Close Won',
                                         CloseDate = System.Today());
        insert opp;
        system.debug(opp.Id);
        
        List<AcctSeed__Billing_Format__c> formatList = new List<AcctSeed__Billing_Format__c>();
        
        AcctSeed__Billing_Format__c defaultBillingFormat = new AcctSeed__Billing_Format__c(Name = 'Billing',
                                                                                          AcctSeed__Type__c = 'Billing',
                                                                                          AcctSeed__Visualforce_PDF_Page__c = 'AccountPayablePost',
                                                                                          AcctSeed__Default_Email_Template__c = 'Interum_Receipt');
        formatList.add(defaultBillingFormat);
        AcctSeed__Billing_Format__c billingActivityStatement = new AcctSeed__Billing_Format__c(Name = 'Billing Activity Statement',
                                                                                          AcctSeed__Type__c = 'Activity Statement',
                                                                                          AcctSeed__Visualforce_PDF_Page__c = 'AccountPayablePost',
                                                                                          AcctSeed__Default_Email_Template__c = 'Interum_Receipt');
        formatList.add(billingActivityStatement);
        AcctSeed__Billing_Format__c billingOutstandingStatement = new AcctSeed__Billing_Format__c(Name = 'Billing Outstanding Statement',
                                                                                          AcctSeed__Type__c = 'Outstanding Statement',
                                                                                          AcctSeed__Visualforce_PDF_Page__c = 'AccountPayablePost',
                                                                                          AcctSeed__Default_Email_Template__c = 'Interum_Receipt');
        formatList.add(billingOutstandingStatement);
        AcctSeed__Billing_Format__c defaultPackingSlip = new AcctSeed__Billing_Format__c(Name = 'Default Packing Slip',
                                                                                          AcctSeed__Type__c = 'Packing Slip	',
                                                                                          AcctSeed__Visualforce_PDF_Page__c = 'AccountPayablePost',
                                                                                          AcctSeed__Default_Email_Template__c = 'Interum_Receipt');
        formatList.add(defaultPackingSlip);
        AcctSeed__Billing_Format__c defaultPurchaseOrder = new AcctSeed__Billing_Format__c(Name = 'Default Purchase Order',
                                                                                          AcctSeed__Type__c = 'Purchase Order',
                                                                                          AcctSeed__Visualforce_PDF_Page__c = 'AccountPayablePost',
                                                                                          AcctSeed__Default_Email_Template__c = 'Interum_Receipt');
    	formatList.add(defaultPurchaseOrder);
        insert formatList;
        
        AcctSeed__GL_Account__c bankAcc = new AcctSeed__GL_Account__c(Name = 'Test', AcctSeed__Sub_Type_1__c = 'Assets',
                                                                     AcctSeed__Bank__c = True);
        insert bankAcc;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(Name = 'Test', AcctSeed__Type__c = 'Transactional',
                                                            AcctSeed__Default_Billing_Format__c = defaultBillingFormat.Id,
                                                            AcctSeed__Billing_Activity_Statement_Format__c = billingActivityStatement.Id,
                                                            AcctSeed__Billing_Outstanding_Statement_Format__c = billingOutstandingStatement.Id,
                                                            AcctSeed__Default_Packing_Slip_Format__c = defaultPackingSlip.Id,
                                                            AcctSeed__Default_Purchase_Order_Format__c = defaultPurchaseOrder.Id,
                                                            AcctSeed__Default_Bank_Account__c = bankAcc.Id);
        insert ledger;
        
        AcctSeedERP__Sales_Order__c salesOrder = new AcctSeedERP__Sales_Order__c(AcctSeedERP__Customer__c = acc.Id,
                                                                                AcctSeedERP__Opportunity__c = opp.Id,
                                                                                AcctSeedERP__Ledger__c = ledger.Id);
        insert salesOrder;
        
        Product2 product = new Product2(Name = 'Test', SKUID_SKU__c = '202', SKUID_Color__c = 'Black');
        insert product;
        
        AcctSeedERP__Sales_Order_Line__c salesOrderLineItem = new AcctSeedERP__Sales_Order_Line__c(AcctSeedERP__Sales_Order__c = salesOrder.Id,
                                                                                                  AcctSeedERP__Quantity_Ordered__c = 1,
                                                                                                  AcctSeedERP__Product__c = product.Id);
        insert salesOrderLineItem;
        
        Wastage.getSalesOrderId(opp.Id);
        Wastage.getSalesOrderRecord(salesOrder.Id);
        Wastage.getSalesOrderItemRecord(salesOrder.Id);
        
        Wastage.WastageWrapper wastageWrapper = new Wastage.WastageWrapper();
        Wastage.SalesOrderItemWrapper saleOrderWrapper = new Wastage.SalesOrderItemWrapper();
        Wastage.getSalesOrderPicklist();
        wastageWrapper.salesOrderItems = new List<Wastage.SalesOrderItemWrapper>{saleOrderWrapper};
        Wastage.insertWastageRecords(wastageWrapper);
        
    }
    
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
}