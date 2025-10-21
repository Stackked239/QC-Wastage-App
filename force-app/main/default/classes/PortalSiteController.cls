public without sharing class PortalSiteController {
    
    @AuraEnabled(cacheable=true)
    public static List<portal_my_order__c> getMyOrders(string userId, string type){
        User userRecord = new User();
        String contactId = userId;
        if(!Test.isRunningTest()){
            // userRecord = [Select Id,Name,ContactId from user where Id =:userId LIMIT 1];
            // contactId = userRecord.ContactId;
            contactId = userId;
        }
        if(type == 'Pending'){
            return [SELECT Id, Name,Stage__c,Balance_Due__c FROM portal_my_order__c where OwnerId  =: contactId AND 
                    (Stage__c  in ('Quote Ready', 'Art Ready') OR Balance_Due__c > 0.0) order by CreatedDate Desc];
        }
        else if(type == 'Completed'){
            return [SELECT Id, Name,Stage__c,Balance_Due__c,Total_Price__c,Tracking_Number__c,CreatedDate FROM portal_my_order__c 
                    where OwnerId  =: contactId AND Production_Stage__c = 'Job Shipped' AND (Balance_Due__c > 0.0 OR Balance_Due__c = null OR Balance_Due__c = 0) 
                    order by CreatedDate DESC];
        }
    
        else if(type == 'Invoice'){
        return [SELECT Id, Name,Stage__c,Balance_Due__c,Total_Price__c,Tracking_Number__c,CreatedDate FROM portal_my_order__c 
                where OwnerId  =: contactId AND (Balance_Due__c > 0.0 ) 
                order by CreatedDate DESC];
        }
        else{
            return [SELECT Id, Name,Stage__c,Needs_Approval_Date__c,Must_Have_Date__c,Balance_Due__c,Total_Price__c,CreatedDate FROM portal_my_order__c 
            where OwnerId  =: contactId AND (Production_Stage__c  != 'Job Shipped' OR Balance_Due__c > 0.0) order by CreatedDate Desc];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<My_Product__c> getOrderProds(string orderId){
        return [SELECT Id, Name,Color__c,Quantity__c,Price_Per_Item__c,Total_Price__c FROM My_Product__c where My_Order__c =: orderId order by CreatedDate Desc];
    }
}