public class displayVideoController {
   
    @AuraEnabled(cacheable=true)
    public static User getUserDetail(){
        String userId = UserInfo.getUserId();
        User u = [Select Id,Name,See_the_video__c from User where Id=:userId LIMIT 1];
        return u;
    }

    @AuraEnabled
    public static void updateUser(){
        String userId = UserInfo.getUserId();
        User u = [Select Id,Name,See_the_video__c from User where Id=:userId LIMIT 1];
        u.See_the_video__c = false;
        update u;
    }
}