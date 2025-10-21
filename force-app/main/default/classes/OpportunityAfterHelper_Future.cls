public class OpportunityAfterHelper_Future {
    
    public static void afterInsert(List<Opportunity> newList) {
        for(Opportunity opp : newList) {
            updateopp(opp.id);
            if(String.isNotBlank(opp.Proof__c)) {
                RTAImageHandler.createFileFromRTAImage(opp.Id);
            }
        }
    }
    
    public static void afterUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        for(Opportunity opp : newList) {
            if(String.isNotBlank(opp.Proof__c) && opp.Proof__c != oldMap.get(opp.Id).Proof__c) {
                RTAImageHandler.createFileFromRTAImage(opp.Id);
            }
        }
    }
    
    @future
    public static void updateopp(id oppid){      
        List<Opportunity>opplist = [Select ID, Contact__c From Opportunity Where Contact__c != null and id =: oppid];
        List<opportunityContactRole> contactrolelist = [select id, contactid from opportunityContactRole where Opportunityid =: oppid];
        if(opplist.size() == 0 && contactrolelist.size() > 0){//There is no contact on opp but there is a contact in contact role       
            Opportunity o = new Opportunity();
            o.id = oppid;
            o.Contact__c = contactrolelist[0].contactid;
            update o;
        }
        if(opplist.size()> 0 && contactrolelist.size()==0){//There is no contact role on opp but there is a contact       
            opportunityContactRole ocr = new opportunityContactRole();
            ocr.ContactId = opplist[0].Contact__c;
            ocr.OpportunityId = oppid;
            insert ocr;
        }
    }
}