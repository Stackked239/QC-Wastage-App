trigger SODeleteTrigger on AcctSeedERP__Sales_Order__c (before delete) {
    for (AcctSeedERP__Sales_Order__c so: Trigger.Old) {if(so.Payment_Made__c == TRUE)
    {
        so.addError('Can not delete Sales Order due to payment by client. Please use Do Not Print and Add Ons to adjust Sales Order');
    }
        }
}