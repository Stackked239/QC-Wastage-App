@IsTest
 private class dlrs_AcctSeedERP_Purchase_OrderTest {
     @IsTest
     static void CreatePurchaseOrder() {
 
         // DATA SETUP
         // insert 6 billing formats
         AcctSeed__Billing_Format__c[] PDFformats = new List<AcctSeed__Billing_Format__c>();
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Billing Product',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Billing',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Billing Service',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Billing',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c (
                         Name = 'Billing Outstanding Statement',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                         AcctSeed__Type__c = 'Outstanding Statement'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c (
                         Name = 'Billing Activity Statement',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                         AcctSeed__Type__c = 'Activity Statement'
                 )
         );
         // #4
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Purchase Order',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Purchase Order',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Packing Slip',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Packing Slip',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         insert PDFformats;
 
         // create GL Accounts
         AcctSeed__GL_Account__c[] glAccounts = new List<AcctSeed__GL_Account__c>();
         // 0
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1000-Cash',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Bank__c = true,
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Cash')
         );
 
         // 1
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1205-Unapplied A/R',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Bank__c = false,
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Cash'
                 )
         );
 
         // 2
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1200-Accounts Receivable',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Current Assets'
                 )
         );
 
         // 3
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1600-Work In Process',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Current Assets'
                 )
         );
 
         // 4
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '2000-Accounts Payable',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Liabilities',
                         AcctSeed__Sub_Type_2__c = 'Current Liabilities'
                 )
         );
 
         // 5
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '2010-Vouchers Payable',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Liabilities',
                         AcctSeed__Sub_Type_2__c = 'Current Liabilities'
                 )
         );
 
         // 6
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '3050-Retained Earnings',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Owners Equity',
                         AcctSeed__Sub_Type_2__c = 'Equity'
                 )
         );
 
         // 7
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '3060-Current Year Earnings',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Owners Equity',
                         AcctSeed__Sub_Type_2__c = 'Equity'
                 )
         );
 
         // 8
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '4000-Product Revenue',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Revenue',
                         AcctSeed__Sub_Type_1__c = 'Product Revenue',
                         AcctSeed__Sub_Type_2__c = 'Product Family 1'
                 )
         );
 
         // 9
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '5010-Inventory Cost Variance',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Expense',
                         AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                         AcctSeed__Sub_Type_2__c = 'Materials'
                 )
         );
 
         // 10
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '5040-Vendor Payment Discounts',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Expense',
                         AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                         AcctSeed__Sub_Type_2__c = 'Materials'
                 )
         );
 
         // 11
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = 'zLabor Clearing',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Expense'
                 )
         );
 
         // 12
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = 'zProject Labor',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Expense'
                 )
         );
 
         // 13
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '4900-Customer Payment Discounts',
                         AcctSeed__Active__c = true,
                         AcctSeed__Bank__c = false,
                         AcctSeed__Type__c = 'Revenue',
                         AcctSeed__Sub_Type_1__c = 'Product Revenue',
                         AcctSeed__Sub_Type_2__c = 'Product Family 1'
                 )
         );
 
         // 14
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1400-Prepaid Expenses',
                         AcctSeed__Active__c = true,
                         AcctSeed__Bank__c = false,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Current Assets'
                 )
         );
 
         insert glAccounts;
 
         // insert 1 Ledger records
         AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
                 Name = 'Actual',
                 AcctSeed__Type__c = 'Transactional',
                 AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                 AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
                 AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
                 AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
                 AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
                 AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
 
         insert ledger;
 
         // update Account Settings with Bill Format
         AcctSeed__Accounting_Settings__c settings = new AcctSeed__Accounting_Settings__c(
                 Name = 'Test Settings',
 
                 AcctSeed__Default_Ledger__c = ledger.Id,
                 AcctSeed__Legacy_Default_Ledger__c = ledger.Id,
                 AcctSeed__Enable_Product_Costing__c = true,
                 AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
                 AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
                 AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true,
                 AcctSeed__Unapplied_Cash_GL_Account__c = glAccounts[1].Id,
                 AcctSeed__AR_Control_GL_Account__c = glAccounts[2].Id,
                 AcctSeed__Work_in_Process_GL_Account__c = glAccounts[3].Id,
                 AcctSeed__AP_Control_GL_Account__c = glAccounts[4].Id,
                 AcctSeed__Vouchers_Payable_GL_Account__c = glAccounts[5].Id,
                 AcctSeed__Retained_Earnings_GL_Account__c = glAccounts[6].Id,
                 AcctSeed__Current_Year_Earnings_GL_Account__c = glAccounts[7].Id,
                 AcctSeed__Revenue_GL_Account__c = glAccounts[8].Id,
                 AcctSeed__Inventory_Variance_GL_Account__c = glAccounts[9].Id,
                 AcctSeed__Payment_Discount_GL_Account__c = glAccounts[10].Id,
                 AcctSeed__Labor_GL_Account__c = glAccounts[11].Id,
                 AcctSeed__Default_Project_Task_Labor_GL_Account__c = glAccounts[12].Id,
                 AcctSeed__Customer_Payment_Adjustment_GL_Account__c = glAccounts[13].Id,
                 AcctSeed__Prepaid_Expense_GL_Account__c = glAccounts[14].Id,
                 AcctSeed__Default_Billing_Format__c = PDFformats[0].Id
 
         );
         insert settings;
 
         // START HERE
          // insert 1 Account
         Account acct = new Account(Name = 'Test');
         insert acct;
         // create Purchase Order
         AcctSeedERP__Purchase_Order__c po = new AcctSeedERP__Purchase_Order__c(
                 AcctSeedERP__Purchase_Order_Format__c = PDFformats[4].Id,
                 AcctSeedERP__Ledger__c = ledger.Id,
                 AcctSeedERP__Vendor__c = acct.Id
 
         );
         insert po;
 
 
         System.assertEquals(1, [Select count() FROM AcctSeedERP__Purchase_Order__c WHERE Id = :po.Id]);
 
     }
 }