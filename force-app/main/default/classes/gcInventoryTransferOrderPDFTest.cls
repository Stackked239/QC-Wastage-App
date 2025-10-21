@IsTest (SeeAllData=TRUE)
private class gcInventoryTransferOrderPDFTest {

    public class gcException extends Exception{}

    @IsTest
    private static void test1(){

        Inventory_Transfer_Order__c order;
        for(Inventory_Transfer_Order__c orderx : [
            SELECT Id 
            FROM Inventory_Transfer_Order__c
            ORDER BY CreatedDate 
            LIMIT 1
        ]){
            order = orderx;
        }

        if(order != null){
            gcInventoryTransferOrderPDF c = new gcInventoryTransferOrderPDF(new ApexPages.StandardController(order));
        }else{
            throw new gcException('In order for the test method to succeed, there must be at least one Inventory Transfer Order in the database.');
        }
    }
}