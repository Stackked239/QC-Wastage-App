trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    
    if(trigger.isBefore && trigger.isInsert){
        for(ContentDocumentLink contentDocLink : trigger.new){
            if(String.valueOf(contentDocLink.LinkedEntityId).startsWith('a8O')){
              contentDocLink.Visibility = 'AllUsers';  
            }
        }
    }

}