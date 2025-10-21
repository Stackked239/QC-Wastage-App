public class OpportunityPDFController {
    
    public Opportunity opportunityRec { get; set; }
    
    private static final String CONGA_ENDPOINT = 'https://composer.congamerge.com/composer8/index.html?';
    public static final String PDF_NAME = 'Opportunity PDF';
        
    public OpportunityPDFController(ApexPages.StandardController controller) {
        opportunityRec = (Opportunity) controller.getRecord();
        opportunityRec = [SELECT Id, Name FROM Opportunity WHERE Id =: opportunityRec.Id];
    }
    
    
    public PageReference generatePDFUsingConga() {
        generatePDFUsingCongaByOppId();
        PageReference pageRef = new PageReference('/'+opportunityRec.Id);
        pageRef.setRedirect(true);
       	return pageRef; 
    }
    
    public void generatePDFUsingCongaByOppId() {
        String oppId = opportunityRec.Id;
        String sessionId = UserInfo.getSessionId();
        String servUrl = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        String endpoint = CONGA_ENDPOINT + 'sessionId=' + sessionId + '&serverUrl=' + EncodingUtil.urlEncode(servUrl, 'UTF-8');
        endpoint += '&id=' + oppId;
        endpoint += '&TemplateId=' + [SELECT APXTConga4__Key__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c =: PDF_NAME LIMIT 1].APXTConga4__Key__c;
        List<String> congaQueriesNameList = new List<String>{'Opportunity By Id', 'Sales Order By Opp Id', 'Sales Order Lines By Opp Id', 'Purchase Orders By Opp Id', 'Content Version By Parent Id'};
        String oppQueryId, salesOrderQueryId, soliQueryId, purchaseOrderQueryId, filesQueryId;
        for(APXTConga4__Conga_Merge_Query__c queryRec : [SELECT Id, Name, APXTConga4__Name__c, APXTConga4__Key__c FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c IN: congaQueriesNameList]) {
            if(queryRec.APXTConga4__Name__c.equalsIgnoreCase('Opportunity By Id')) oppQueryId = queryRec.APXTConga4__Key__c;
            else if(queryRec.APXTConga4__Name__c.equalsIgnoreCase('Sales Order By Opp Id')) salesOrderQueryId = queryRec.APXTConga4__Key__c;
            else if(queryRec.APXTConga4__Name__c.equalsIgnoreCase('Sales Order Lines By Opp Id')) soliQueryId = queryRec.APXTConga4__Key__c;
            else if(queryRec.APXTConga4__Name__c.equalsIgnoreCase('Purchase Orders By Opp Id')) purchaseOrderQueryId = queryRec.APXTConga4__Key__c;
            else if(queryRec.APXTConga4__Name__c.equalsIgnoreCase('Content Version By Parent Id')) filesQueryId = queryRec.APXTConga4__Key__c;
        }
        String fileName = opportunityRec.name.replaceAll(' ', '+');
        endpoint += '&QueryId=[Opportunity]'+oppQueryId+'?pv0='+oppId+',[SalesOrder]'+salesOrderQueryId+'?pv0='+oppId+',[POs]'+purchaseOrderQueryId+'?pv0='+oppId+',[SalesOrderLines]'+soliQueryId+'?pv0='+oppId+',[FileImage]'+filesQueryId+'?pv0='+oppId+'&OFN='+fileName+'&defaultPDF=1&QMode=SalesforceFile&SC0=1&SC1=SalesforceFile&APIMODE=1';    // if there are issues, Conga recommends trying to remove the DS7 (background mode) param
        System.debug('endpoint: ' + endpoint);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();       
        request.setMethod('GET');
        request.setTimeout(120000);    // conga recommends setting a long timeout for generation
        request.setEndpoint(endpoint);
        request.setHeader('Authorization',  'Bearer ' + sessionId);
        HttpResponse response = http.send(request);
        system.debug('Response::'+response.getBody());
        if(response.getStatusCode() != 200 || response.getBody().containsIgnoreCase('error')) {
            system.assert(false,response.getStatusCode()+'   '+ response.getBody());
        }
    }
}