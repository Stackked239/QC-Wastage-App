@IsTest
 public class SODeleteTest {
 
     @IsTest
     public static void testCreateSalesOrder() {
 
 // insert GL Accounts
         List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1000-Cash',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Bank__c = true,
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Cash'
                 )
         );
         insert glAccounts;
 
 // insert Billing Formats
         List<AcctSeed__Billing_Format__c> billingFormats = new List<AcctSeed__Billing_Format__c>();
         billingFormats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Billing Product',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Billing',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         billingFormats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Billing Service',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Billing',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         billingFormats.add(
                 new AcctSeed__Billing_Format__c (
                         Name = 'Billing Outstanding Statement',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                         AcctSeed__Type__c = 'Outstanding Statement'
                 )
         );
 
         billingFormats.add(
                 new AcctSeed__Billing_Format__c (
                         Name = 'Billing Activity Statement',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                         AcctSeed__Type__c = 'Activity Statement'
                 )
         );
 
         billingFormats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Purchase Order',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Purchase Order',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         billingFormats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Packing Slip',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Packing Slip',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         insert billingFormats;
 
 // insert 1 Ledger record
         List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
 
         ledgers.add(
                 new AcctSeed__Ledger__c(
                         Name = 'Actual',
                         AcctSeed__Type__c = 'Transactional',
                         AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                         AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                         AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                         AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                         AcctSeed__Default_Purchase_Order_Format__c = billingFormats[4].Id,
                         AcctSeed__Default_Packing_Slip_Format__c = billingFormats[5].Id
                 )
         );
 
         insert ledgers;
 // insert 1 Account
         Account acct = new Account(Name = 'Test');
         insert acct;
 
 // insert 1 Product
         Product2 prod = new Product2(
                 Name = 'Sample'
         );
         insert prod;
 
 // --- START HERE ---
 
         List<AcctSeedERP__Sales_Order__c> salesOrders = new List<AcctSeedERP__Sales_Order__c>();
         salesOrders.add(
                 new AcctSeedERP__Sales_Order__c(
                         AcctSeedERP__Customer__c = acct.Id,
                         AcctSeedERP__Ledger__c = ledgers[0].Id,
                     	 Payment_Made__c = TRUE
                 )
         );
 
         insert salesOrders;
 
         System.assertEquals(1, [Select count() FROM AcctSeedERP__Sales_Order__c WHERE Id = :salesOrders[0].Id]);
 
         AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c(
                 AcctSeedERP__Product__c = prod.id,
                 AcctSeedERP__Quantity_Ordered__c = 1,
                 AcctSeedERP__Sales_Order__c = salesOrders[0].id
             
             
         );
 
         insert sol;
         System.assertEquals(1, [Select count() FROM AcctSeedERP__Sales_Order_Line__c WHERE Id = :sol.Id]);
 
 // Perform test
 	Test.startTest();
         Database.DeleteResult result = Database.delete(salesOrders[0].id, false) ;
    Test.stopTest();
 //Verify
	System.assert(!result.isSuccess());
    System.assert(result.geterrors().size() > 0);
    System.assertEquals('Can not delete Sales Order due to payment by client. Please use Do Not Print and Add Ons to adjust Sales Order', result.getErrors()[0].getmessage());     
     }
 }