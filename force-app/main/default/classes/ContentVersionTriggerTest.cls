@isTest
private class ContentVersionTriggerTest {
    @isTest static void testTrigger() {
        // Create a ContentVersion with Approval
        ContentVersion approvedVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            Approved__c = true
        );
        insert approvedVersion;

        // Ensure the version is marked as approved
        ContentVersion fetchedVersion = [
            SELECT Id, ContentDocumentId, Approved__c 
            FROM ContentVersion 
            WHERE Id = :approvedVersion.Id
        ];
        System.assertEquals(true, fetchedVersion.Approved__c);

        // Insert a new ContentVersion for the same document
        ContentVersion newVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf('Test Content New'),
            IsMajorVersion = true,
            ContentDocumentId = fetchedVersion.ContentDocumentId,
            Approved__c = true
        );
        insert newVersion;

        // The trigger should have unapproved the previous version
        fetchedVersion = [
            SELECT Id, ContentDocumentId, Approved__c 
            FROM ContentVersion 
            WHERE Id = :fetchedVersion.Id
        ];
        System.assertEquals(false, fetchedVersion.Approved__c);

        // Check the new version is marked as approved
        ContentVersion fetchedNewVersion = [
            SELECT Id, ContentDocumentId, Approved__c 
            FROM ContentVersion 
            WHERE Id = :newVersion.Id
        ];
        System.assertEquals(true, fetchedNewVersion.Approved__c);
    }
}