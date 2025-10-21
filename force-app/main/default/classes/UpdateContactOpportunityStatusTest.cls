@isTest(SeeAllData=true)
private class UpdateContactOpportunityStatusTest {

    @isTest
    static void testWithExistingContact() {
        // Use the specific Contact ID provided
        Id contactId = '0034w000049byY8AAI';
        
        // Query the Contact
        Contact existingContact = [SELECT Id, HasOpenOpportunity__c FROM Contact WHERE Id = :contactId LIMIT 1];

        // Proceed with the test using the existing contact
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity with Existing Contact',
            StageName = 'Lead In',  // Open stage
            CloseDate = Date.today().addDays(30),
            ContactId = existingContact.Id,
            OwnerId = UserInfo.getUserId()  // Assuming the Flow might need this
        );
        insert opp;

        // Verify the Contact's checkbox is checked
        existingContact = [SELECT HasOpenOpportunity__c FROM Contact WHERE Id = :contactId];
        System.assertEquals(true, existingContact.HasOpenOpportunity__c);

        // Update Opportunity to a 'Closed' stage
        opp.StageName = 'Closed Won';
        update opp;

        // Verify the Contact's checkbox is unchecked
        existingContact = [SELECT HasOpenOpportunity__c FROM Contact WHERE Id = :contactId];
        System.assertEquals(false, existingContact.HasOpenOpportunity__c);
    }

    @isTest
    static void testOpportunityDeletedForExistingContact() {
        // Use the specific Contact ID provided
        Id contactId = '0034w000049byY8AAI';
        
        // Query the Contact
        Contact existingContact = [SELECT Id, HasOpenOpportunity__c FROM Contact WHERE Id = :contactId LIMIT 1];

        // Create an Opportunity related to the existing Contact
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity to Delete',
            StageName = 'Lead In',  // Open stage
            CloseDate = Date.today().addDays(30),
            ContactId = existingContact.Id,
            OwnerId = UserInfo.getUserId()  // Assuming the Flow might need this
        );
        insert opp;

        // Verify the Contact's checkbox is checked
        existingContact = [SELECT HasOpenOpportunity__c FROM Contact WHERE Id = :contactId];
        System.assertEquals(true, existingContact.HasOpenOpportunity__c);

        // Delete the Opportunity
        delete opp;

        // Verify the Contact's checkbox is unchecked after deletion
        existingContact = [SELECT HasOpenOpportunity__c FROM Contact WHERE Id = :contactId];
        System.assertEquals(false, existingContact.HasOpenOpportunity__c);
    }
}