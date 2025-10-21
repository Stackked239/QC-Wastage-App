public without sharing class gcInventoryTransferOrderPDF {

    public gcInventoryTransferOrderPDF(ApexPages.StandardController c){
        init(c.getId());
    }

    public transient wrapTfr wrapTfr{get;set;}

    public class wrapTfr{
        public Inventory_Transfer_Order__c tfr{get;set;}
    }

    public void init(Id tfrId)
    {
        wrapTfr = new wrapTfr();
        wrapTfr.tfr = [
            SELECT Id,
                    Name,
                    Destination_Location__r.Name,
                    Destination_Location__r.AcctSeedERP__Warehouse__r.Name,
                    Origin_Location__r.Name,
                    Origin_Location__r.AcctSeedERP__Warehouse__r.Name,
                    //Destination_Warehouse__r.Name,
                    //Origin_Warehouse__r.Name,
                    CreatedDate,
                    (SELECT Id,
                            Name,
                            Product__c,
                            Product__r.GTIN_1__c,
                            Product__r.GTIN_2__c,
                            Product__r.Name,
                            Product__r.ProductCode,
                            Box_Count_Sent__c,
                            Quantity_Sent__c
                    FROM Inventory_Transfer_Order_Lines__r
                    ORDER BY Name)
            FROM Inventory_Transfer_Order__c 
            WHERE Id =: tfrId][0];
    }
}