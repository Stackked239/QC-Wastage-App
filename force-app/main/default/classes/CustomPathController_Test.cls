@isTest
public class CustomPathController_Test {
    
    @isTest 
    public static void testArtApprevedCase() {
        portal_my_order__c order = new portal_my_order__c();
        order.Stage__c = 'Art Ready';
        insert order;
        
        Test.startTest();
        CustomPathController.fetchStatus(order.Id);
        Test.stopTest();
    }
    
}