trigger OpportunityAfterTrigger on Opportunity (after insert, after update) {
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            OpportunityAfterHelper_Future.afterInsert(trigger.new);
        }
        if(trigger.isUpdate) {
            OpportunityAfterHelper_Future.afterUpdate(trigger.new, trigger.oldMap);
        }
    }
}