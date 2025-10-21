@isTest
public with sharing class displayVideoController_Test {
   @isTest
   static void userDetailTest(){

    Profile p =[Select Id, name from profile where Name='System Administrator'];
    User u = new User();
    u.FirstName = 'John';
    u.LastName = 'Doe';
    u.Username = 'jdoe12@example.com';
    u.Email = 'jdoe12@example.com';
    u.Alias = 'jdoe';
    u.CommunityNickname = 'jdoe';
    u.TimeZoneSidKey = 'America/New_York';
    u.LocaleSidKey = 'en_US';
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    u.ProfileId = p.Id;
    u.See_the_video__c = false;
    insert u;
    
    displayVideoController.getUserDetail();
    displayVideoController.updateUser();
   }
}