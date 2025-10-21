trigger UpdateContactOpportunityStatus on Opportunity (after insert, after update, after delete, after undelete) {
    
    Set<Id> contactIds = new Set<Id>();

    // Collect Contact IDs from Trigger context (insert, update, undelete)
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Opportunity opp : Trigger.new) {
            if (opp.ContactId != null) {
                contactIds.add(opp.ContactId);
            }
        }
    }

    // Handle deletion of Opportunities
    if (Trigger.isDelete) {
        for (Opportunity opp : Trigger.old) {
            if (opp.ContactId != null) {
                contactIds.add(opp.ContactId);
            }
        }
    }

    // Map to store the Contact Ids and their associated count of open opportunities
    Map<Id, Integer> contactToOpenOppCount = new Map<Id, Integer>();

    // Query to count the number of Opportunities with stage type 'Open'
    for (AggregateResult ar : [
            SELECT ContactId, COUNT(Id) total
            FROM Opportunity
            WHERE ContactId IN :contactIds AND StageName IN (
                'Lead In', 
                'Needs Quoted', 
                'Quote Sent', 
                'Production Schedule/Quote Approval'
            )
            GROUP BY ContactId
        ]) {
        contactToOpenOppCount.put((Id)ar.get('ContactId'), (Integer)ar.get('total'));
    }

    // List to store Contacts that need to be updated
    List<Contact> contactsToUpdate = new List<Contact>();

    // Loop through the Contact Ids and determine if the checkbox needs to be checked or unchecked
    for (Id contactId : contactIds) {
        Integer openOppCount = contactToOpenOppCount.get(contactId);
        Contact contactToUpdate = new Contact(Id = contactId);
        
        // Checkbox should be checked if there are open opportunities, otherwise unchecked
        contactToUpdate.HasOpenOpportunity__c = (openOppCount != null && openOppCount > 0);

        contactsToUpdate.add(contactToUpdate);
    }

    // Update Contacts
    if (!contactsToUpdate.isEmpty()) {
        update contactsToUpdate;
    }
}