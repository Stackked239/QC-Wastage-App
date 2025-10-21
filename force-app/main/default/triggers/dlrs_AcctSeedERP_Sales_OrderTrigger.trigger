/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AcctSeedERP_Sales_OrderTrigger on AcctSeedERP__Sales_Order__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(AcctSeedERP__Sales_Order__c.SObjectType);
}