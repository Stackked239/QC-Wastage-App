@isTest
private class GenerateCodeBeforeInsertTest {
    @isTest 
    static void testGenerateUniqueCodeSuccess() {
        // Create a Contact dynamically
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User');
        insert testContact;

        Test.startTest();

        // Create a discount code
        Discount_Code__c dc = new Discount_Code__c(Name = 'TEST', Contact__c = testContact.Id);
        insert dc;

        // Verify it was assigned correctly
        Discount_Code__c insertedDC = [SELECT Name FROM Discount_Code__c WHERE Id = :dc.Id];
        System.assert(insertedDC.Name.startsWith('TEST'), 'Generated code should start with TEST');
        System.assertEquals(9, insertedDC.Name.length(), 'Generated code should be 5 characters longer than prefix.');

        Test.stopTest();
    }
}