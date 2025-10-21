@isTest
public class OpportunityPDFControllerTest {
	
    @isTest
    static void testPDFGeneration() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact con = new Contact(LastName = 'test');
        insert con;
        
        Opportunity opp = new Opportunity(Name  = 'Opp Test');
        opp.StageName = 'Prospect';
        opp.CloseDate = system.today().addDays(20);
        opp.AccountId = acc.Id;
        opp.ContactId = con.Id;
        opp.Proof__c = '<p><img src="https://cdn.wccftech.com/wp-content/uploads/2018/02/Google.jpg" alt="142-1424998_bootstrap-logo.png"></img></p>';
        insert opp;
        
        APXTConga4__Conga_Template__c congaTemplate = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = OpportunityPDFController.PDF_NAME);
		insert congaTemplate;
        
        Test.setMock(HttpCalloutMock.class, new CongaMockGenerator());
        Test.StartTest(); 
			ApexPages.StandardController sc = new ApexPages.StandardController(opp);
			OpportunityPDFController  obj = new OpportunityPDFController(sc);
        	obj.generatePDFUsingConga();
		Test.StopTest();
    }
    
    public class CongaMockGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('success');
            return res;
        }
    }
    
}