@isTest
public class QuoteAfterTrigger_Test {
    @isTest
    public static void testquote(){
        Contact c = new Contact();
        c.LastName = 'Sanchez';
        insert c;
        Account a = new Account();
        a.Name = 'testA';
        insert a;
        Opportunity o = new Opportunity();
        o.Name = 'testO';
        o.AccountId = a.id;
        o.CloseDate = system.today();
        o.StageName = 'Needs Quoted';
        o.Contact__c = c.id;
        insert o;
        Quote q = new Quote();
        q.Name = 'TestQ';
        q.OpportunityId = o.id;
        insert q;
        
        o.Contact__c = null;
        update o;
        opportunityContactRole ocr = new opportunityContactRole();
        ocr.ContactId = c.id;
        ocr.OpportunityId = o.id;
        insert ocr;
        Quote q2 = new Quote();
        q2.Name = 'TestQ';
        q2.OpportunityId = o.id;
        insert q2;
        
        Opportunity o2 = new Opportunity();       
        o2.Name = 'testO2';
        o2.AccountId = a.id;
        o2.CloseDate = system.today();
        o2.StageName = 'Needs Quoted';
        o2.Contact__c = c.id;
        insert o2;
    }
}