public class RTAImageHandler {
    
    public static FINAL String RTA_FILE_NAME = 'RTA-Proof.jpg';
    
    @future(callout=true)
    public static void createFileFromRTAImage(String oppId) {
        if(String.isNotBlank(oppId)) {
            Opportunity opp = [Select Id,Proof__c, production_Date__c,Must_have_date__c from opportunity WHERE Id =: oppId];
            Matcher imgMatcher = Pattern.compile( '<img(.+?)>' ).matcher(opp.Proof__c);  
            
            List<ContentVersion> cvInsertList = new List<ContentVersion>();
            while (imgMatcher.find()) {            
                String imageTag = imgMatcher.group();
                
                String imageURL= imageTag.substringBetween(' src="', '"' );
                
                String decodedURL = imageURL.unescapeHtml4();
                PageReference page = new PageReference( decodedURL );
                Blob b = Test.isRunningTest() ? Blob.valueOf('<p>test</p>') : page.getContent();
                
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S';
                conVer.PathOnClient = RTA_FILE_NAME;
                conVer.Title = RTA_FILE_NAME;
                conVer.VersionData = b;
                cvInsertList.add(conVer);
            }
            delete [Select Id FROM ContentDocumentLink WHERE LinkedEntityId =: opp.Id AND ContentDocument.Title =: RTA_FILE_NAME];
            if(!cvInsertList.isEmpty()) {
                insert cvInsertList;
                List<ContentDocumentLink> cdLinkInsertList = new List<ContentDocumentLink>();
                List<ContentDistribution> contentDistributionInsertList = new List<ContentDistribution>();
                for(ContentVersion conVer : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvInsertList]) {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = opp.Id;
                    conDocLink.ContentDocumentId = conVer.ContentDocumentId;
                    conDocLink.shareType = 'V';
                    cdLinkInsertList.add(conDocLink);
                    
                    contentDistributionInsertList.add(createContentDistribution(conVer.Id));
                }
                insert cdLinkInsertList;
                insert contentDistributionInsertList;
                List<ContentVersion> cvUpdateList = new List<ContentVersion>();
                for(ContentDistribution cd : [Select Id, ContentVersionId, ContentDownloadUrl FROM ContentDistribution WHERE Id IN: contentDistributionInsertList]) {
                    ContentVersion cv = getContentVersionWithPublicImageURL(cd);
                    if(cv != null) {
                        cvUpdateList.add(cv);
                    }
                }
                update cvUpdateList;
                /**
                update new Opportunity(
                    Id = opp.Id, 
                    Image_URL__c = getContentVersionWithPublicImageURL(cd.Id)                    
                );**/
            }
        }
    }
    
    public static ContentVersion getContentVersionWithPublicImageURL(ContentDistribution cd) {
        if(cd != null) {
            String url = cd.ContentDownloadUrl;
            url = url.replace('download/?', 'renditionDownload/?rendition=ORIGINAL_Jpg&');
            url += '&versionId=' + cd.ContentVersionId;
            return new ContentVersion(
                Id = cd.ContentVersionId,
            	Public_Image_URL__c = url
            );
        }
        return null;
    }
    
    public static ContentDistribution createContentDistribution(Id contentVersionId) {
        ContentDistribution newDist = new ContentDistribution();
        newDist.ContentVersionId = contentVersionId;
        newDist.Name = 'External Link';
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        newDist.PreferencesAllowOriginalDownload=true;
        return newDist;
    }
}