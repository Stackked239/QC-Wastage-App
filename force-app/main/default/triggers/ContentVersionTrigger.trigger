Trigger ContentVersionTrigger on ContentVersion (before insert) {
    // Fetch the new ContentVersions from the trigger
    List<ContentVersion> newVersions = Trigger.new;

    // Extract the document Ids from the new versions
    Set<Id> documentIds = new Set<Id>();
    for (ContentVersion version : newVersions) {
        documentIds.add(version.ContentDocumentId);
    }

    // Fetch existing approved versions of these documents
    Map<Id, ContentVersion> approvedVersions = new Map<Id, ContentVersion>();
    for (ContentVersion version : [
        SELECT Id, Approved__c, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :documentIds AND Approved__c = true
    ]) {
        approvedVersions.put(version.ContentDocumentId, version);
    }

    // Iterate over the new versions again and unapprove previous versions if necessary
    for (ContentVersion version : newVersions) {
        ContentVersion previousVersion = approvedVersions.get(version.ContentDocumentId);
        if (previousVersion != null) {
            previousVersion.Approved__c = false;
        }
    }

    // Finally, update the previous versions
    update approvedVersions.values();
}