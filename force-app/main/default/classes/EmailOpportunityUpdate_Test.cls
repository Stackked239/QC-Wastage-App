/**************************************************************************************************
* Class Name	: EmailOpportunityUpdate_Test
* Author		: Pranav
* Date: 		: 26-May-2022
* group			: Wakencode
* Description	: This test class is covering EmailOpportunityUpdate
**************************************************************************************************/

@isTest
public class EmailOpportunityUpdate_Test {
    
    @TestSetup
    static void init() {
        //Create an Account for the opportunity to be created
        Account acc = new Account();
        acc.Name = 'ABC Test';
        insert acc;
                
        //create a new opportunity with email subject as job reference number
        Opportunity Opp = new Opportunity();
        Opp.Name = 'tasty test';
        Opp.Accountid = acc.id;
        Opp.StageName = 'Pre Qualification';
        Opp.closedate = Date.Today()+2;
        insert Opp;
        
    }
    
    @isTest 
    static void testArtApprevedCase() {
        // setup controller object
        EmailOpportunityUpdate objconfirm = new EmailOpportunityUpdate();
        
        Opportunity testop1 = [select id, Opportunity_Number__c from Opportunity];
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = testop1.Opportunity_Number__c.replace('-','')+' Has Been Approved';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.';
        envelope.fromAddress = 'test@test.com';
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        Opportunity testop2 = [select id, Opportunity_Number__c, Ashore_Approved__c, Ashore_Revision__c from Opportunity where id = :testop1.id];
        
        System.assertEquals(testop2.Ashore_Approved__c,true);
        System.assertEquals(testop2.Ashore_Revision__c,false);
        
    }
    
    @isTest 
    static void testArtNotApproved() {
        // setup controller object
        EmailOpportunityUpdate objconfirm = new EmailOpportunityUpdate();
        
        Opportunity testop1 = [select id, Opp_Account__c, Opportunity_Number__c from Opportunity];
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = testop1.Opp_Account__c+' Marked '+testop1.Opportunity_Number__c.replace('-','')+' Not Approved';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.';
        envelope.fromAddress = 'test@test.com';
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        Opportunity testop2 = [select id, Opportunity_Number__c, Ashore_Approved__c, Ashore_Revision__c from Opportunity where id = :testop1.id];
        
        System.assertEquals(testop2.Ashore_Revision__c,true);
        System.assertEquals(testop2.Ashore_Approved__c,false);
        
    }
    
    @isTest 
    static void testNewCommentsCase() {
        // setup controller object
        EmailOpportunityUpdate objconfirm = new EmailOpportunityUpdate();
        
        Opportunity testop1 = [select id, Opp_Account__c, Opportunity_Number__c from Opportunity];
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = 'There are New Comments on'+testop1.Opportunity_Number__c.replace('-','');
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.';
        envelope.fromAddress = 'test@test.com';
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,false);
        
        Opportunity testop2 = [select id, Opportunity_Number__c, Ashore_Approved__c, Ashore_Revision__c from Opportunity where id = :testop1.id];
        
        System.assertEquals(testop2.Ashore_Revision__c,false);
        System.assertEquals(testop2.Ashore_Approved__c,false);
        
    }
    
    @isTest 
    static void testStageStartedCase() {
        // setup controller object
        EmailOpportunityUpdate objconfirm = new EmailOpportunityUpdate();
        
        Opportunity testop1 = [select id, Opp_Account__c, Opportunity_Number__c from Opportunity];
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = testop1.Opportunity_Number__c.replace('-','') + ' Stage 1 has started';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.';
        envelope.fromAddress = 'test@test.com';
        
        Messaging.InboundEmailResult result = objconfirm.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);
        
        Opportunity testop2 = [select id, Opportunity_Number__c, Ashore_Approved__c, Ashore_Revision__c from Opportunity where id = :testop1.id];
        
        System.assertEquals(testop2.Ashore_Revision__c,false);
        System.assertEquals(testop2.Ashore_Approved__c,false);
        
    }
    
}