/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AcctSeedERP_Sales_Order_LineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AcctSeedERP_Sales_Order_LineTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new AcctSeedERP__Sales_Order_Line__c());
    }
}