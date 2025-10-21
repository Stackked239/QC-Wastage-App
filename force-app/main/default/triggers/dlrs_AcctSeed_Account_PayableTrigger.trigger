/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AcctSeed_Account_PayableTrigger on AcctSeed__Account_Payable__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(AcctSeed__Account_Payable__c.SObjectType);
}