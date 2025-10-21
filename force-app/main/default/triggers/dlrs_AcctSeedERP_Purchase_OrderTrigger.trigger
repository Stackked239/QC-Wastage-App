trigger dlrs_AcctSeedERP_Purchase_OrderTrigger on AcctSeedERP__Purchase_Order__c (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(AcctSeedERP__Purchase_Order__c.SObjectType);
}