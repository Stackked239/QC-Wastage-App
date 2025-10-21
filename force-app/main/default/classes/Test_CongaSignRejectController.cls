@isTest 
public class Test_CongaSignRejectController {
    
     @isTest
     static void testMethod1(){
         Account acc1 = new Account();
         acc1.Name = 'test account';
         insert acc1;
         
         Opportunity Opp1 = new Opportunity();
         Opp1.Name = 'testOpp';
         Opp1.AccountId = acc1.Id;
         Opp1.StageName = 'Needs Quoted';
         Opp1.CloseDate = system.Today();
         insert Opp1;        
         
         
         Product2 Pro1 = new Product2();
         Pro1.Name = 'SLA: Bronze';
         pro1.isActive = True;
         Insert pro1;
         
         Pricebook2 pb = new pricebook2();
         pb.Name = 'Standard Price Book 2009';
         pb.description = 'Price Book 2009 Products';
         pb.isActive = True;
         insert pb;
         
         
         Id pricebookId = Test.getStandardPricebookId();        
         
         PricebookEntry StandardPriceBookEntry = new PricebookEntry();
         StandardPriceBookEntry.Pricebook2Id = pricebookId;
         StandardPriceBookEntry.Product2Id = pro1.Id;
         StandardPriceBookEntry.UnitPrice = 10000;
         StandardPriceBookEntry.IsActive =True;        
         insert StandardPriceBookEntry;
         
         
         PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=pro1.id, unitprice=10000, isActive = True);
         insert pbe;
         
         Quote Quo1 = new Quote(); 
         Quo1.OpportunityId = Opp1.Id;
         Quo1.Pricebook2Id = pb.Id;
         Quo1.Name = 'test Quo1';      
         insert Quo1;   
         
         QuoteLineItem QLI  = new QuoteLineItem();
         QLI.Product2Id = pro1.Id;
         QLI.QuoteId = Quo1.Id;
         QLI.PricebookEntryId = Pbe.Id;
         QLI.Quantity = 2;
         QLI.UnitPrice = 150000.0; 
         insert QLI;    
         
         PageReference pageRef = Page.vfp_CongaSignRejectForm;
         pageRef.getParameters().put('Id', String.valueOf(Quo1.Id));
         pageRef.getParameters().put('commentsInput', 'test');
         Test.setCurrentPage(pageRef);
         
         CongaSignRejectController obj = new CongaSignRejectController();
         obj.saveRejectedFormData();
    }
		

}