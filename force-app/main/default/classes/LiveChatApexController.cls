public class LiveChatApexController {

    @AuraEnabled
    public static List<user> fetchUser(){    
      return [select id,Name,Email from user where id=:UserInfo.getUserId()];

    }

}