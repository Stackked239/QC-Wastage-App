/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AcctSeedERP_Inventory_BalanceTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AcctSeedERP_Inventory_Bala1sTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new AcctSeedERP__Inventory_Balance__c());
    }
}