@isTest
public class SC_ArtProofingDetailApex_Test {
    @isTest
    static void testgetLoggedInUser(){
        SC_ArtProofingDetailApex.getLoggedInUserDetails();
    }
    @isTest
    static void testcreateorUpdateComments(){
        
        portal_my_order__c myorder = new portal_my_order__c();
        myorder.Name = 'test';
        myorder.stage__c = 'Art Ready';
        insert myorder; 
        
        List<SC_ArtProofingDetailApex.CommentWrapper> commentList = new List<SC_ArtProofingDetailApex.CommentWrapper>();
       
        SC_ArtProofingDetailApex.CommentWrapper comm = new SC_ArtProofingDetailApex.CommentWrapper();
        comm.commDescription = 'Test Description';
        comm.xPosition = '21212';
        comm.yPosition = '212212';
        comm.commentNumber = 1;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=myorder.id;
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        comm.fileId = documents[0].Id;
        comm.versionId = contentVersion.Id;
        comm.ordId = myorder.Id;
        commentList.add(comm);
        
        SC_ArtProofingDetailApex.createorUpdateComments(commentList);
        SC_ArtProofingDetailApex.getComments(myorder.Id,documents[0].Id,contentVersion.Id);
        SC_ArtProofingDetailApex.fetchFilesRelatedToOrder(myorder.Id);
        SC_ArtProofingDetailApex.fetchPendingArtApproval('Art Approval');
        SC_ArtProofingDetailApex.fetchPendingArtApproval('Pending Order');
        SC_ArtProofingDetailApex.fetchPendingArtApproval(' ');
        SC_ArtProofingDetailApex.saveProofInRevision(contentVersion.Id, documents[0].Id,new List<String>{'Apparel color'},myorder.Id);
        
        List<SC_ArtProofingDetailApex.FileInfo> fileInfoList = new List<SC_ArtProofingDetailApex.FileInfo>();
        SC_ArtProofingDetailApex.FileInfo fileInfo = new SC_ArtProofingDetailApex.FileInfo();
        fileInfo.Title = 'test';
        fileInfo.VersionData =  Blob.valueOf('Test Content');
        fileInfoList.add(fileInfo);
        
//        SC_ArtProofingDetailApex.saveFiles(fileInfoList,myorder.Id);
 
    }
    @isTest
    static void testupdateCoordinates(){
        portal_my_order__c myorder = new portal_my_order__c();
        myorder.Name = 'test';
        insert myorder; 
        
        
        Comments__c comm = new Comments__c();
        comm.Name = 'test';
        insert comm;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=myorder.id;
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        List<SC_ArtProofingDetailApex.contentVersionWrapper> commVersionList = new List<SC_ArtProofingDetailApex.contentVersionWrapper>(); 
    
        SC_ArtProofingDetailApex.contentVersionWrapper commVersion = new SC_ArtProofingDetailApex.contentVersionWrapper();
        
        commVersion.versionId = contentVersion.Id;
        commVersion.isLatest = true;
        commVersion.lastViewDate = System.Today();
        
        commVersionList.add(commVersion);
        
        SC_ArtProofingDetailApex.updateContentVersion(commVersionList,(String)myorder.Id);
        
        SC_ArtProofingDetailApex.updateCoordinates(comm.Id,'223','223'); 
        
        SC_ArtProofingDetailApex.updateStage(myorder.Id,'Art Ready',documents[0].Id);
        
    }

}