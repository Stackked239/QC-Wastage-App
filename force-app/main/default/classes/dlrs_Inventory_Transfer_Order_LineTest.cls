/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Inventory_Transfer_Order_LineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Inventory_Transfer_Order_a9wTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Inventory_Transfer_Order_Line__c());
    }
}