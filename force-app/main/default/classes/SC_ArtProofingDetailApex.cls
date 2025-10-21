public class SC_ArtProofingDetailApex {
    
    
    @AuraEnabled
    public static User getLoggedInUserDetails(){
        return [select id,contact.Name,name,TimeZoneSidKey, UserType from User where id = : UserInfo.getUserId()];
    }
    
    @AuraEnabled
    public static void createorUpdateComments(List<CommentWrapper> commentList){
        system.debug('commentList'+commentList);
        List<Comments__c> commentToBeUpdated = new List<Comments__c>();
        for(CommentWrapper wrapp : commentList){
            Comments__c comm = new Comments__c();
            comm.Comment_Description__c = wrapp.commDescription;
            if(string.isNotBlank(wrapp.recordId)){
                comm.Id =   wrapp.recordId;
            }
            comm.PositionX__c = wrapp.xPosition;
            comm.PositionY__c = wrapp.yPosition;
            comm.Comment_Number__c = wrapp.commentNumber;
            comm.File_Version__c = wrapp.versionId;
            comm.Id_of_File__c = wrapp.fileId;
            comm.My_Order__c = wrapp.ordId;
            commentToBeUpdated.add(comm);
        }
        if(!commentToBeUpdated.isEmpty()){
            upsert commentToBeUpdated;
        }
    }
    @AuraEnabled
    public static List<CommentWrapper> getComments(String OrderId,String fileId,String versionId){
        system.debug('getComments ');
        List<CommentWrapper> commWrapperList = new List<CommentWrapper>();
        for(Comments__c comm : [SELECT id, Name,PositionX__c,PositionY__c,File_Version__c,Id_of_File__c,
                                Owner.Name, My_Order__c, Comment_Number__c,
                                Comment_Description__c, CreatedBy.Name, CreatedDate, CreatedBy.TimeZoneSidKey 
                                FROM Comments__c 
                                WHERE My_Order__c=:OrderId AND File_Version__c=:versionId AND Id_of_File__c=:fileId
                                ORDER BY CreatedDate Asc]){
                                    CommentWrapper commwrapp = new CommentWrapper();
                                    commwrapp.commentNumber = integer.valueOf(comm.Comment_Number__c);
                                    commwrapp.commDescription = comm.Comment_Description__c;
                                    commwrapp.xPosition = comm.PositionX__c;
                                    commwrapp.yPosition =  comm.PositionY__c;
                                    commwrapp.versionId = comm.File_Version__c;
                                    commwrapp.fileId = comm.Id_of_File__c;
                                    commwrapp.ordId = comm.My_Order__c;
                                    commwrapp.recordId = comm.Id;
                                    commwrapp.ownerName = comm.owner.Name;
                                    commwrapp.createdBy = comm.CreatedBy.Name;
                                    commwrapp.createdDateTime = comm.CreatedDate;
                                    commwrapp.timeZoneSidKey = comm.CreatedBy.TimeZoneSidKey;
                                    commWrapperList.add(commwrapp);
                                }
        return commWrapperList;
    }
    
    @AuraEnabled
    public static void updateCoordinates(String recordId,String x,String y){
        system.debug('updateCoordinates ');
        Comments__c comm = new Comments__c();
        comm.Id = recordId;
        comm.PositionX__c = x;
        comm.PositionY__c = y;
        update comm;
    }
    @AuraEnabled
    public static FileWrapper fetchFilesRelatedToOrder(String orderId){
        system.debug('fetchFilesRelatedToOrder ');
        String excludeFiles =  Label.ExcludeFilePrefix;
        Set<Id> contentdocIds = new Set<Id>();
        List<portal_my_order__c> orders = [select id,name, CreatedDate,stage__c,Must_Have_Date__c,In_Revision__c, Needs_Approval_Date__c, Revision_Needed_By_Date__c, Approved_On__c,Submit_Revision_Time__c from portal_my_order__c where id=:orderId];
        for(ContentDocumentLink ContentDocLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:orderId And Visibility='AllUsers']){
            contentdocIds.add(ContentDocLink.ContentDocumentId);
        }
        Set<Id> fetchdocSet = new Set<Id>(); 
        
        List<ContentDocument> fetchDocuments = new List<ContentDocument>();
        
        for(ContentDocument fetchDocument : [select id,Title from ContentDocument where Id In: contentdocIds ORDER BY LastModifiedDate desc]){
            if(!fetchDocument.Title.startsWith(excludeFiles)){
                fetchdocSet.add(fetchDocument.Id);
                fetchDocuments.add(fetchDocument);
            }
        }
        List<ContentVersion> contentVersionList =  [SELECT Id,ContentDocumentId, Approved__c, Revision_Choices__c, VersionNumber,Last_View_Date__c, PathOnClient, IsLatest FROM ContentVersion where ContentDocumentId In:fetchdocSet ORDER BY IsLatest desc, Approved__c desc, LastModifiedDate desc];
        
        FileWrapper wrapp = new FileWrapper();
        wrapp.contentVersionsList = contentVersionList;
        wrapp.contentDocumentsList = fetchDocuments;
        wrapp.portalOrder = orders.size()>0 ? orders[0] : null;
        return wrapp;
        
    }
    
    @AuraEnabled
    public static void updateContentVersion( List<contentVersionWrapper> contentVersionList, String orderId){
        try {      
            Set<String> setOfContentVersionId = new Set<String>();
            
            for(contentVersionWrapper contentVersionWrap: contentVersionList) {
                setOfContentVersionId.add(contentVersionWrap.versionId);
            }
            User u =[Select Id,ContactId from User where Id=: UserInfo.getUserId() LIMIT 1];
            
            if(u.ContactId!=null || Test.isRunningTest()){
                portal_my_order__c order = [select id,name, Latest_Last_View_Date__c from portal_my_order__c where id=:orderId LIMIT 1];
                
                if(order!=null){
                    order.Latest_Last_View_Date__c = System.today();
                    update as System order;
                }
                
                List<ContentVersion> listOfContentVersion = [SELECT Id,ContentDocumentId,Last_View_Date__c from ContentVersion where Id In:setOfContentVersionId AND IsLatest=true];
                if(!listOfContentVersion.isEmpty()){
                    for(ContentVersion cv: listOfContentVersion){
                        cv.Last_View_Date__c = System.today();
                    }update as System listOfContentVersion;}}} catch (Exception e) {throw new AuraHandledException(e.getMessage());
           }
    }
    
    public class contentVersionWrapper{
        @AuraEnabled public string versionId{get;set;} 
        @AuraEnabled public boolean isLatest{get;set;}
        @AuraEnabled public date lastViewDate{get;set;}
    }
    
    
    @AuraEnabled
    public static List<OrderWrapper> fetchPendingArtApproval(String type){
        system.debug('fetchPendingArtApproval ');
        Map<Id,portal_my_order__c> orderMap = new Map<Id,portal_my_order__c>();
        Map<Id,Id> contentDocLinkMap = new Map<Id,Id>();
        Map<Id,ContentDocument> contentDocumentMap = new Map<Id,ContentDocument>();
        Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion>();
        List<Portal_my_order__c> portalOrder = new List<Portal_my_order__c>();
        String excludeFiles =  Label.ExcludeFilePrefix;
        
        String query = 'SELECT id,name, Must_Have_Date__c, Needs_Approval_Date__c, Revision_Needed_By_Date__c, Stage__c, Approved_On__c FROM Portal_my_order__c WHERE ';
        
        if(type == 'Art Approval'){ 
            query += 'stage__c = \'Art Ready\''; 
        }
        else if(type == 'Pending Order'){
            query += 'stage__c = \'Art Approved\' OR stage__c=\'Sizes Submitted\' OR stage__c=\'Scheduled for Production\'';
        }
        else{
            query += 'Stage__c= \'Art Started\' AND (In_Revision__c = true OR Submit_Revision_Time__c != null)';
        }
        //query += ' LIMIT 40';
        System.debug('query  '+query);
        portalOrder = Database.query(query);
        
        for(portal_my_order__c order : portalOrder){
            orderMap.put(order.Id,order);
        }
        If(orderMap!=null && orderMap.keyset().size()>0){
            for(ContentDocumentLink ContentDocLink : [SELECT ContentDocumentId,ContentDocument.Title,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId  In:orderMap.keyset() And Visibility='AllUsers' order by SystemModstamp asc]){
                if(!ContentDocLink.ContentDocument.Title.startsWith(excludeFiles)){
                    contentDocLinkMap.put(ContentDocLink.LinkedEntityId,ContentDocLink.ContentDocumentId);
                }
            }
            for(ContentDocument contdoc :   [select id,Title from ContentDocument where Id In: contentDocLinkMap.values() ORDER BY LastModifiedDate desc]){   
                if(!contdoc.Title.startsWith(excludeFiles)){
                    contentDocumentMap.put(contdoc.Id,contdoc);
                }
            }
            List<ContentVersion> contentVersionList =  [SELECT Id,ContentDocumentId, VersionNumber, IsLatest, PathOnClient FROM ContentVersion where ContentDocumentId In:contentDocumentMap.keyset() ORDER BY LastModifiedDate asc];
            for(ContentVersion conversion : contentVersionList){
                contentVersionMap.put(conversion.ContentDocumentId,conversion);
            }
            List<OrderWrapper> orderWrapperList = new  List<OrderWrapper>();
            for(Id orderId : contentDocLinkMap.keyset()){
                if(contentDocLinkMap.containskey(orderId)){
                    Id contdocId = contentDocLinkMap.get(orderId);
                    OrderWrapper wrapp = new OrderWrapper();
                    wrapp.portalOrder = orderMap.get(orderId);
                    wrapp.contentDocument = contentDocumentMap.containskey(contdocId) ? contentDocumentMap.get(contdocId) : null;
                    wrapp.contentVersion = contentVersionMap.containskey(contdocId) ? contentVersionMap.get(contdocId) : null;
                    if(wrapp.contentDocument!=null &&  wrapp.contentVersion!=null){
                        orderWrapperList.add(wrapp);
                    }
                    
                }
            }
            return orderWrapperList;
        }
        return null;
    }
    
    @AuraEnabled
    public static void saveProofInRevision (String contentVerId,String fileId,List<String> SelectedChoices,String myOrderId){
         system.debug('saveProofInRevision ');
        try {         
            ContentVersion Conversion = new ContentVersion();
            Conversion.Id = contentVerId;
            Conversion.Revision_Choices__c = String.join(SelectedChoices,';');
            update Conversion;
            
            /* Comments__c comm = new Comments__c();
comm.Comment_Description__c = Comment;
comm.My_Order__c = myOrderId;
comm.File_Version__c = contentVerId;
comm.Id_of_File__c = fileId;
insert comm; */
            
            portal_my_order__c portalmyorder = new portal_my_order__c();
            portalmyorder.Stage__c = 'Art Started';
           // portalmyorder.In_Revision__c = true;
            portalmyorder.Id = myOrderId;
            portalmyorder.Submit_Revision_Time__c = DateTime.now();
            update portalmyorder;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateInRevision (String myOrderId){
        try {         
            portal_my_order__c portalmyorder = new portal_my_order__c(Id = myOrderId,
                                                                      In_Revision__c = true );
            UPDATE portalmyorder;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* @AuraEnabled
public static void saveFiles(list<Object> filesToInsert, String orderId){        
list<Id> lstCntVerIds = new list<Id>();
List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
List<ContentDocumentLink> conDocLink = new List<ContentDocumentLink>();
for (Object file : filesToInsert) {
FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);

ContentVersion objCntVersion = new ContentVersion();
objCntVersion.PathOnClient = fileData.Title;
objCntVersion.Title = fileData.Title;
objCntVersion.VersionData = fileData.VersionData;
lstVersionsToInsert.add(objCntVersion);
}
list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
for (Database.SaveResult saveResult : res) {
if(saveResult.isSuccess()){
lstCntVerIds.add(saveResult.getId());  
}
}
if(lstCntVerIds != null && lstCntVerIds.size() > 0){
for(ContentVersion conVer : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: lstCntVerIds]){
ContentDocumentLink contentlink=new ContentDocumentLink();
contentlink.LinkedEntityId=orderId;
// contentlink.ShareType= '';
contentlink.ContentDocumentId= conVer.ContentDocumentId;
contentlink.Visibility = 'AllUsers';
conDocLink.add(contentlink);
}
if(conDocLink != null && conDocLink.size() > 0)
INSERT conDocLink; 
}
}*/
    
    @AuraEnabled
    public static void updateStage (String myOrderId, String stage,String fileId){ 
        system.debug('updateStage ');
        try{   
            portal_my_order__c portalmyorder = new portal_my_order__c(Id = myOrderId,
                                                                      Stage__c = stage,//'Art Approved',
                                                                      In_Revision__c = false);   
            if(stage == 'Art Approved'){
                portalmyorder.Approved_On__c = System.today();
                List<contentversion> Latestcontentverstion = [select id from contentversion where ContentDocumentId=:fileId And isLatest=true];
                if(Latestcontentverstion.size()>0){
                    Latestcontentverstion[0].Approved__c = true;
                    update Latestcontentverstion;
                }
            }
            
            UPDATE portalmyorder;       
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static void uploadNewVersions(List<String> newfileIds , String displayedFileId){
        system.debug('uploadNewVersions ');
        List<ContentVersion> newContentVersionList = new List<ContentVersion>();
        for(ContentVersion contentversion : [select contentdocumentId,PathOnClient,Title,VersionData  from ContentVersion where contentdocumentId IN:newfileIds]){
            
            // Map<String, Object> contentMap = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( contentversion ) );
            
            //contentMap.remove('Id');
            
            ContentVersion newContentVersion = new ContentVersion(); 
            newContentVersion.Title = contentversion.Title;
            newContentVersion.PathOnClient = contentversion.PathOnClient;
            newContentVersion.VersionData = contentversion.VersionData;
            newContentVersion.contentdocumentId = displayedFileId;
            newContentVersion.Revision_Choices__c= null;
            newContentVersionList.add(newContentVersion);
        }
        if(newContentVersionList.size()>0){
            insert newContentVersionList;
        }
        
        if(newfileIds.size()>0){
            delete [select Id from ContentDocument where Id IN:newfileIds];
        }
        
        // newContentVersionList[0].contentdocumentId = displayedFileId;
        // update newContentVersionList;
        
    }
    
    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }
    
    public class CommentWrapper{
        @AuraEnabled public integer commentNumber{get;set;} 
        @AuraEnabled public string commDescription{get;set;}
        @AuraEnabled public string xPosition{get;set;}
        @AuraEnabled public string yPosition{get;set;}
        @AuraEnabled public string recordId{get;set;}
        @AuraEnabled public string versionId{get;set;}
        @AuraEnabled public string fileId{get;set;}
        @AuraEnabled public string ordId{get;set;}
        @AuraEnabled public string ownerName{get;set;}
        @AuraEnabled public string createdBy{get;set;}
        @AuraEnabled public Datetime createdDateTime{get;set;}
        @AuraEnabled public string timeZoneSidKey{get;set;}
        @AuraEnabled public String userInitials{get;set;}
        @AuraEnabled public boolean hasCommentNumber{get;set;}
    }
    
    public class FileWrapper{
        @AuraEnabled public portal_my_order__c portalOrder;
        @AuraEnabled public List<ContentVersion> contentVersionsList;
        @AuraEnabled public List<ContentDocument> contentDocumentsList;
        
    }
    public class OrderWrapper{
        @AuraEnabled public portal_my_order__c portalOrder;
        @AuraEnabled public ContentDocument contentDocument;
        @AuraEnabled public ContentVersion contentVersion;
    }
}