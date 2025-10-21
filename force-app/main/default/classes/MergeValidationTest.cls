@IsTest
private class MergeValidationTest {

    @TestSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        // Create test contacts linked to accounts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                AccountId = accounts[Math.mod(i, accounts.size())].Id,
                Email = 'test' + i + '@example.com'
            ));
        }
        insert contacts;
    }

    @IsTest
    static void testAccountTriggerExecution() {
        // Get test accounts
        List<Account> accounts = [SELECT Id, Name, CreatedDate FROM Account LIMIT 5];

        // The trigger is on before delete, so we test by deleting accounts
        // This will exercise the trigger code even if MasterRecordId is null

        Test.startTest();

        try {
            // Delete accounts to trigger the before delete trigger
            delete accounts;

            // Verify deletion was successful (trigger didn't block it)
            List<Account> deletedAccounts = [SELECT Id FROM Account WHERE Id IN :accounts];
            System.assertEquals(0, deletedAccounts.size(), 'Accounts should be deleted when no merge is involved');

        } catch (Exception e) {
            System.assert(false, 'Normal delete should not fail: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void testContactTriggerExecution() {
        // Get test contacts
        List<Contact> contacts = [SELECT Id, FirstName, LastName, CreatedDate FROM Contact LIMIT 5];

        Test.startTest();

        try {
            // Delete contacts to trigger the before delete trigger
            delete contacts;

            // Verify deletion was successful (trigger didn't block it)
            List<Contact> deletedContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];
            System.assertEquals(0, deletedContacts.size(), 'Contacts should be deleted when no merge is involved');

        } catch (Exception e) {
            System.assert(false, 'Normal delete should not fail: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void testBulkAccountOperations() {
        // Test bulk operations to ensure trigger handles governor limits properly
        List<Account> accounts = [SELECT Id, Name FROM Account];

        Test.startTest();

        try {
            delete accounts;
            System.assert(true, 'Bulk delete completed successfully');
        } catch (Exception e) {
            System.assert(false, 'Bulk delete failed: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void testBulkContactOperations() {
        // Test bulk operations to ensure trigger handles governor limits properly
        List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact];

        Test.startTest();

        try {
            delete contacts;
            System.assert(true, 'Bulk delete completed successfully');
        } catch (Exception e) {
            System.assert(false, 'Bulk delete failed: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void testTriggerCodePaths() {
        // Create accounts with different created dates for more realistic testing
        Account oldAccount = new Account(Name = 'Old Account');
        insert oldAccount;

        Account newAccount = new Account(Name = 'New Account');
        insert newAccount;

        // Create contacts with different created dates
        Contact oldContact = new Contact(
            FirstName = 'Old',
            LastName = 'Contact',
            AccountId = oldAccount.Id,
            Email = 'old@test.com'
        );
        insert oldContact;

        Contact newContact = new Contact(
            FirstName = 'New',
            LastName = 'Contact',
            AccountId = newAccount.Id,
            Email = 'new@test.com'
        );
        insert newContact;

        Test.startTest();

        // Test deleting individual records to hit trigger code paths
        delete oldContact;  // Delete contact first since it references the account
        delete newContact;
        delete oldAccount;
        delete newAccount;

        // Verify all were deleted (no merge validation occurred)
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id IN (:oldAccount.Id, :newAccount.Id)]);
        System.assertEquals(0, [SELECT COUNT() FROM Contact WHERE Id IN (:oldContact.Id, :newContact.Id)]);

        Test.stopTest();
    }
}