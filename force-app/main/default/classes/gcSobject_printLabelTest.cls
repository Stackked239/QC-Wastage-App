@isTest(SeeAllData=TRUE)
private class gcSobject_printLabelTest{
    
    static testMethod void test1(){
        gcSobject_printLabel c;
        ApexPages.StandardSetController ssc;

        list<Sobject> listObj;

        for(String objectName : new list<String>{'Account','Asset','Campaign','Case','Contact','Order','Product2','AcctSeedERP__Purchase_Order_Line__c'}){
            
            //collect some records
            listObj = Database.query('SELECT Id FROM '+objectName+' LIMIT 2');

            if(!listObj.isEmpty()){

                //launch with default controller
                ApexPages.currentPage().getParameters().put('id',listObj[0].Id);
                c = new gcSobject_printLabel();

                //launch print page from detail page
                c = new gcSobject_printLabel(new ApexPages.StandardController(listObj[0]));
                //System.Assert(!c.labels.isEmpty());

                //launch print page(s) from list view
                ssc = new ApexPages.StandardSetController(listObj);
                ssc.setSelected(listObj);
                c = new gcSobject_printLabel(ssc);
                //System.Assert(!c.labels.isEmpty());                 
            }
        }
    }
}