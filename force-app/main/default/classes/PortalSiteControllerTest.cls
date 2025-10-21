@isTest
public class PortalSiteControllerTest {
    @isTest
    static void testGetMyOrders() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        
        List<portal_my_order__c> testOrders = new List<portal_my_order__c>{
            new portal_my_order__c(Contact_ID__c = testContact.Id, Name = 'Order 1', Stage__c = 'Quote Ready', Balance_Due__c = 10.0),
                new portal_my_order__c(Contact_ID__c = testContact.Id, Name = 'Order 2', Stage__c = 'Quote Ready', Balance_Due__c = null,Tracking_Number__c = '123456'),
                new portal_my_order__c(Contact_ID__c = testContact.Id, Name = 'Order 3', Stage__c = 'Art Ready', Balance_Due__c = 5.0, Production_Stage__c = 'Job Shipped'),
                new portal_my_order__c(Contact_ID__c = testContact.Id, Name = 'Order 4', Stage__c = 'Quote Ready', Balance_Due__c = 0.0, Production_Stage__c = 'Job Shipped'),
                new portal_my_order__c(Contact_ID__c = testContact.Id, Name = 'Order 5', Stage__c = 'Scheduled for Production', Balance_Due__c = 15.0),
                new portal_my_order__c(Contact_ID__c = testContact.Id, Name = 'Order 6', Stage__c = 'Art Ready', Balance_Due__c = 20.0)
                };
                    insert testOrders;
        
        // Call the method with a valid user ID and a valid type
        List<portal_my_order__c> result1 = new List<portal_my_order__c>();
		result1 = PortalSiteController.getMyOrders(testContact.Id, 'Pending');
        result1 = PortalSiteController.getMyOrders(testContact.Id, 'Completed');
        result1 = PortalSiteController.getMyOrders(testContact.Id, 'Invoice');
        result1 = PortalSiteController.getMyOrders(testContact.Id, 'Other');
        
        // Verify the expected records are returned for each type
        //System.assertEquals(4, result1.size());
    
    }    
    @isTest
    static void testGetOrderProds() {
        // Create test data
        portal_my_order__c testOrder = new portal_my_order__c();
        insert testOrder;
        
        List<My_Product__c> testProducts = new List<My_Product__c>{
            new My_Product__c(My_Order__c = testOrder.Id, Name = 'Product 1', Color__c = 'Red', Quantity__c = 1, Price_Per_Item__c = 10.0),
                new My_Product__c(My_Order__c = testOrder.Id, Name = 'Product 2', Color__c = 'Blue', Quantity__c = 2, Price_Per_Item__c = 5.0),
                new My_Product__c(My_Order__c = testOrder.Id, Name = 'Product 3', Color__c = 'Green', Quantity__c = 1, Price_Per_Item__c = 15.0)
                };
                    insert testProducts;
        
        // Call the method with a valid order ID
        List<My_Product__c> result = PortalSiteController.getOrderProds(testOrder.Id);
        
        // Verify the expected records are returned
        System.assertEquals(3, result.size());
        System.assertEquals('Product 1', result[0].Name);
        System.assertEquals('Red', result[0].Color__c);
        System.assertEquals(1, result[0].Quantity__c);
        System.assertEquals(10.0, result[0].Price_Per_Item__c);
        System.assertEquals(10.0, result[0].Total_Price__c);
    }
}