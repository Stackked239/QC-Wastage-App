trigger QuoteAfterTrigger on Quote (after insert) {
    
    for(Quote q : trigger.new){
        if(trigger.isInsert && trigger.isAfter){
            if(q.ContactId == null){
                Quote qu = new Quote();
                qu.id = q.id;
                Opportunity oppContact = [select ID, Contact__c From Opportunity Where ID =: q.OpportunityId];
                if(oppContact.Contact__c != null){                    
                    qu.ContactId = oppContact.Contact__c;
                    update qu;
                }else{//opp doesnt have a contact, go check if contact role has one
                    List<opportunityContactRole> oprole = [select id, contactid from opportunityContactRole where Opportunityid =: q.OpportunityId];
                    if(oprole.size()>0){
                        qu.ContactId = oprole[0].contactid;
                        update qu;
                    }
                }
            }  
        } 
    }
}