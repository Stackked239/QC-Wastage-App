public with sharing class gcSobject_printLabel {

    public Id idParent{get;set;}
    private set<Id> setIdFilter{get;set;}
    public transient list<label> labels{get;set;}
    private Schema.SObjectType objectType;

    public gcSobject_printLabel(){
        
        Id myId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
        setIdFilter = new set<Id>();
        setIdFilter.add(myId);
        objectType = ((Id)myId).getSObjectType();
        createLabels();
    }

    public gcSobject_printLabel(ApexPages.StandardController c){

        idParent = c.getId();
        objectType = idParent.getSObjectType();

        setIdFilter = new set<Id>();
        setIdFilter.add(idParent);
        createLabels();
    }

    public gcSobject_printLabel(ApexPages.StandardSetController sc){

        setIdFilter = new set<Id>();

        for(Sobject obj : (List<Sobject>)sc.getSelected()){
            setIdFilter.add(obj.Id);
            if(objectType == null)
                objectType = obj.getSObjectType();
        }

        if(objectType != null && !setIdFilter.isEmpty()){
           createLabels(); 
        }else{
            labels = new list<label>();
        }
    }

    public void createLabels(){

        if(objectType == Schema.AcctSeedERP__Purchase_Order__c.SobjectType){
            createLabels_purchaseOrderLine();
        }else if(objectType == Schema.AcctSeedERP__Purchase_Order_Line__c.SobjectType){
            createLabels_purchaseOrderLine();
        }else{
            createLabels_sobject();
        }
    }

    public void createLabels_sobject(){

        String soql = '';
        soql += ' SELECT Id ';
        
        if(objectType.getDescribe().fields.getMap().containsKey('Name'))
            soql += ', Name';
        
        if(objectType.getDescribe().fields.getMap().containsKey('Barcode__c'))
            soql += ', Barcode__c';
        
        if(objectType == Schema.Asset.SobjectType){
            soql += ', SerialNumber';
            soql += ', Product2.Name';
            soql += ', Product2.ProductCode';
            soql += ', Product2.GTIN_1__c';
        }else if(objectType == Schema.Case.SobjectType){
            soql += ', CaseNumber';
        }else if(objectType == Schema.Product2.SobjectType){
            soql += ', Case_Count__c';
            soql += ', Family';
            soql += ', GTIN_1__c';
            soql += ', ProductCode';
            soql += ', StockKeepingUnit';
            soql += ', Size__c';
        }
        soql += ', CreatedDate ';
        soql += ' FROM ';
        soql += objectType.getDescribe().getName();
        soql += ' WHERE Id IN :setIdFilter ';

        if(objectType == Case.SobjectType){
            soql += ' ORDER BY CaseNumber ';
        }else if(objectType.getDescribe().fields.getMap().containsKey('Name')){
            soql += 'ORDER BY Name, Id ';
        }else{
            soql += 'ORDER BY CreatedDate, Id ';
        }

        soql += ' LIMIT 300 ';

        labels = new list<label>();
        for(Sobject obj : Database.Query(soql)){
            labels.add(new label(obj));
        }
    }

    public void createLabels_purchaseOrderLine(){

        labels = new list<label>();
        
        //create a minimum of ONE label for each Purchase Order Line
        //if the quantity unreceived is greater than 1, create additional labels, up to 100
        for(AcctSeedERP__Purchase_Order_Line__c polx : [
            SELECT Id,
                    AcctSeedERP__Product__c,
                    AcctSeedERP__Product__r.Id,
                    AcctSeedERP__Product__r.Case_Count__c,
                    AcctSeedERP__Product__r.GTIN_1__c,
                    AcctSeedERP__Product__r.Name,
                    AcctSeedERP__Product__r.ProductCode,
                    AcctSeedERP__Product__r.Size__c,
                    AcctSeedERP__Quantity__c,
                    AcctSeedERP__Quantity_Unreceived__c
            FROM AcctSeedERP__Purchase_Order_Line__c
            WHERE AcctSeedERP__Product__r.Id != null 
              AND (Id IN:setIdFilter
                    OR AcctSeedERP__Purchase_Order__c IN :setIdFilter)
            ORDER BY AcctSeedERP__Product__r.Name 
        ]){
            Decimal labelQty = 1;
            if(polx.AcctSeedERP__Quantity_Unreceived__c != null && polx.AcctSeedERP__Quantity_Unreceived__c > 1){
                labelQty = polx.AcctSeedERP__Quantity_Unreceived__c;
            }

            if(labelQty == null || labelQty < 1)
                labelQty = 1;

            if(polx.AcctSeedERP__Product__r.Case_Count__c != null && polx.AcctSeedERP__Product__r.Case_Count__c >= 1)
                labelQty = labelQty / polx.AcctSeedERP__Product__r.Case_Count__c;
            
            Long labelCount = labelQty.round(System.RoundingMode.CEILING);
            if(labelCount < 0)
                labelCount = labelCount * (-1);

            if(labelCount > 100) labelCount = 100;
            
            for(Long i=1; i<= labelCount; i++){
                labels.add(new label(polx));
            }
        }
    }

    public class label{

        public Sobject obj{get;set;}
        public Product2 product{get;set;}

        public label(SObject pObj){

            if (pObj.getSObjectType() == Schema.Product2.SobjectType){

                this.product = (Product2)pObj;

            }else if(pObj.getSObjectType() == Schema.AcctSeedERP__Purchase_Order_Line__c.SobjectType){

                AcctSeedERP__Purchase_Order_Line__c pol = (AcctSeedERP__Purchase_Order_Line__c)pObj;
                
                //system.debug(loggingLevel.error,'*** pol: '+pol);
                
                if(pol.AcctSeedERP__Product__c != null)
                    this.product = (Product2)pol.AcctSeedERP__Product__r;
                else 
                    this.obj = pObj;
            }
            else{
                this.obj = pObj;
            }
        }
    }
}