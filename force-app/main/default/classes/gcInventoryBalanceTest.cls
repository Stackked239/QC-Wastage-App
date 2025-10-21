@IsTest (SeeAllData=TRUE)
private class gcInventoryBalanceTest {

    public class gcException extends Exception{}

    @IsTest
    private static void test1(){

        AcctSeedERP__Inventory_Balance__c bal;
        for(AcctSeedERP__Inventory_Balance__c balx : [
            SELECT Id,
                    AcctSeedERP__Ledger__c,
                    AcctSeedERP__Location__c,
                    AcctSeedERP__Location__r.AcctSeedERP__Warehouse__c,
                    AcctSeedERP__Product__c
            FROM AcctSeedERP__Inventory_Balance__c
            LIMIT 1
        ]){
            bal = balx;
        }

        if(bal == null){
            throw new gcException('The test method cannot succeed, unless there is at least one Inventory Quantity Available record in the database.');
        }

        //find the existing balance
        gcInventoryBalance.findOrCreateBalance(bal.AcctSeedERP__Product__c,bal.AcctSeedERP__Location__c);

        //create a new Inventory Location, in order to create a new Inventory Balance
        AcctSeedERP__Location__c loc = new AcctSeedERP__Location__c(
            Name = (String.valueOf(dateTime.now())).left(40),
            AcctSeedERP__Warehouse__c = bal.AcctSeedERP__Location__r.AcctSeedERP__Warehouse__c
        );
        insert loc;

        //create a new Inventory Balance
        gcInventoryBalance.findOrCreateBalance(bal.AcctSeedERP__Product__c,loc.Id);
    }
}