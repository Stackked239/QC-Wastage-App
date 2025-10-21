/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AcctSeedERP_Sales_Order_LineTrigger on AcctSeedERP__Sales_Order_Line__c
    (before delete, before insert, before update, after undelete)
{
    dlrs.RollupService.triggerHandler(AcctSeedERP__Sales_Order_Line__c.SObjectType);
}