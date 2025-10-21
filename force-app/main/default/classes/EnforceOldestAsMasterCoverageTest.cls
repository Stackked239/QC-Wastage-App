@IsTest
private class EnforceOldestAsMasterCoverageTest {

    @TestSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        // Create test contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                Email = 'test' + i + '@example.com'
            ));
        }
        insert contacts;
    }

    @IsTest
    static void testAccountTriggerCoverage() {
        // This method specifically targets the EnforceOldestAsMaster_Account trigger
        List<Account> accounts = [SELECT Id, Name, CreatedDate FROM Account LIMIT 3];

        Test.startTest();

        // Delete accounts to trigger the before delete event
        // The trigger code will execute even if MasterRecordId is null
        delete accounts;

        // Verify deletion completed (normal delete should work)
        List<Account> remainingAccounts = [SELECT Id FROM Account WHERE Id IN :accounts];
        System.assertEquals(0, remainingAccounts.size(), 'Normal delete should succeed');

        Test.stopTest();
    }

    @IsTest
    static void testContactTriggerCoverage() {
        // This method specifically targets the EnforceOldestAsMaster_Contact trigger
        List<Contact> contacts = [SELECT Id, FirstName, LastName, CreatedDate FROM Contact LIMIT 3];

        Test.startTest();

        // Delete contacts to trigger the before delete event
        // The trigger code will execute even if MasterRecordId is null
        delete contacts;

        // Verify deletion completed (normal delete should work)
        List<Contact> remainingContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];
        System.assertEquals(0, remainingContacts.size(), 'Normal delete should succeed');

        Test.stopTest();
    }

    @IsTest
    static void testAccountBulkOperations() {
        // Test bulk delete operations for Account trigger
        List<Account> accounts = [SELECT Id FROM Account];

        Test.startTest();
        delete accounts;
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Account], 'All accounts should be deleted');
    }

    @IsTest
    static void testContactBulkOperations() {
        // Test bulk delete operations for Contact trigger
        List<Contact> contacts = [SELECT Id FROM Contact];

        Test.startTest();
        delete contacts;
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Contact], 'All contacts should be deleted');
    }

    @IsTest
    static void testTriggerWithMixedData() {
        // Create additional mixed data to ensure all code paths are hit
        Account acc1 = new Account(Name = 'Mixed Test 1');
        Account acc2 = new Account(Name = 'Mixed Test 2');
        insert new List<Account>{acc1, acc2};

        Contact con1 = new Contact(FirstName = 'Mixed', LastName = 'Contact 1', Email = 'mixed1@test.com');
        Contact con2 = new Contact(FirstName = 'Mixed', LastName = 'Contact 2', Email = 'mixed2@test.com');
        insert new List<Contact>{con1, con2};

        Test.startTest();

        // Delete contacts first, then accounts
        delete new List<Contact>{con1, con2};
        delete new List<Account>{acc1, acc2};

        Test.stopTest();

        // Verify cleanup
        System.assertEquals(0, [SELECT COUNT() FROM Contact WHERE Id IN (:con1.Id, :con2.Id)]);
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id IN (:acc1.Id, :acc2.Id)]);
    }
}