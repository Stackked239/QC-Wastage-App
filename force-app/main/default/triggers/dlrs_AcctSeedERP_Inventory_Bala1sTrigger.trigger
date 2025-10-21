/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AcctSeedERP_Inventory_Bala1sTrigger on AcctSeedERP__Inventory_Balance__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(AcctSeedERP__Inventory_Balance__c.SObjectType);
}