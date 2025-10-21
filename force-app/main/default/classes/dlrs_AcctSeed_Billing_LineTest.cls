/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AcctSeed_Billing_LineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AcctSeed_Billing_LineTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new AcctSeed__Billing_Line__c());
    }
}