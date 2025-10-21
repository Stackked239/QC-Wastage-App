public without sharing class GuidanceSystemController {
    
    @AuraEnabled
    public static List<Community_Guidance_System__c> findAll() {
        List<Community_Guidance_System__c> CGSList = [SELECT Id, Name, is_First_Message__c, is_Last_Message__c, Main_Message__c, Message_No__c, Page_Number__c, Title__c 
                                                      FROM Community_Guidance_System__c ];
        Boolean walkthrough = [SELECT Id, Name, Walkthrough_Guide__c FROM User WHERE Id = :UserInfo.getUserId()].Walkthrough_Guide__c;
        if(walkthrough){
            return CGSList;
        }
        return null;
        
    }
    
    @AuraEnabled
    public static void hideWalkthrough() {
        List<User> userList = [SELECT Id, Name, Walkthrough_Guide__c FROM User WHERE Id = :UserInfo.getUserId()];
        User userObj = new User();
        if(userList.size()>0){
            userObj = userList[0];
            userObj.Walkthrough_Guide__c = false;
        }
        update userObj;
        
    }
    
}