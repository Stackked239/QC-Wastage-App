/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Inventory_Transfer_Order_a9wTrigger on Inventory_Transfer_Order_Line__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Inventory_Transfer_Order_Line__c.SObjectType);
}