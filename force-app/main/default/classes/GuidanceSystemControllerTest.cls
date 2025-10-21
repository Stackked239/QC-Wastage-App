@isTest
public class GuidanceSystemControllerTest {
    
    @TestSetup
    public static void init() {
    	Community_Guidance_System__c cgs = new Community_Guidance_System__c();
        cgs.is_First_Message__c = true;
        cgs.is_Last_Message__c = false;
        cgs.Main_Message__c = 'test message';
        cgs.Message_No__c = 1;
        cgs.Page_Number__c = 1;
        cgs.Title__c = 'test title';
        
        insert cgs;
                
    }
    
    @isTest 
    public static void testArtApprevedCase() {
        Test.startTest();
        GuidanceSystemController.findAll();
        GuidanceSystemController.hideWalkthrough();
        Test.stopTest();
    }

}