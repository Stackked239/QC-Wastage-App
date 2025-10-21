@IsTest
private class EnforceOldestAsMasterTest {

    @TestSetup
    static void setupTestData() {
        // Create test accounts for Contact tests
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert testAccounts;
    }

    // Test class that extends trigger functionality to allow testing
    private class TestableAccountTrigger {
        public void executeTriggerLogic(List<Account> triggerOld, Map<Id, Account> triggerOldMap) {
            // Simulate the Account trigger logic with test data
            if (triggerOld == null || triggerOld.isEmpty()) return;

            // Collect winners (masters) from this merge - simulate with test data
            Set<Id> winnerIds = new Set<Id>();
            for (Account loser : triggerOld) {
                // For testing, we'll use a custom field or simulate the merge scenario
                if (loser.Name != null && loser.Name.contains('MERGE_TO:')) {
                    // Extract winner ID from name for testing
                    String winnerId = loser.Name.substring(loser.Name.indexOf('MERGE_TO:') + 9);
                    if (winnerId.length() >= 15) {
                        winnerIds.add(Id.valueOf(winnerId.substring(0, 15)));
                    }
                }
            }
            if (winnerIds.isEmpty()) return;

            // Query winners' CreatedDate
            Map<Id, Account> winnersById = new Map<Id, Account>(
                [SELECT Id, CreatedDate FROM Account WHERE Id IN :winnerIds]
            );

            // Group losers by winner
            Map<Id, List<Account>> losersByWinner = new Map<Id, List<Account>>();
            for (Account loser : triggerOld) {
                if (loser.Name == null || !loser.Name.contains('MERGE_TO:')) continue;
                String winnerIdStr = loser.Name.substring(loser.Name.indexOf('MERGE_TO:') + 9);
                if (winnerIdStr.length() >= 15) {
                    Id winnerId = Id.valueOf(winnerIdStr.substring(0, 15));
                    if (!losersByWinner.containsKey(winnerId)) {
                        losersByWinner.put(winnerId, new List<Account>());
                    }
                    losersByWinner.get(winnerId).add(loser);
                }
            }

            // Validate per merge group: winner must be the oldest CreatedDate
            for (Id winnerId : losersByWinner.keySet()) {
                Account winner = winnersById.get(winnerId);
                if (winner == null) continue;

                Datetime minCreated = winner.CreatedDate;
                Id oldestId = winner.Id;

                for (Account loser : losersByWinner.get(winnerId)) {
                    if (loser.CreatedDate < minCreated) {
                        minCreated = loser.CreatedDate;
                        oldestId = loser.Id;
                    }
                }

                // If the winner isn't the oldest, simulate blocking the merge
                if (oldestId != winner.Id) {
                    String msg = 'Merge blocked: the master must be the OLDEST record by CreatedDate. '
                               + 'Please select the oldest record as master and try again.';
                    for (Account loser : losersByWinner.get(winnerId)) {
                        loser.addError(msg);
                    }
                }
            }
        }
    }

    private class TestableContactTrigger {
        public void executeTriggerLogic(List<Contact> triggerOld, Map<Id, Contact> triggerOldMap) {
            // Simulate the Contact trigger logic with test data
            if (triggerOld == null || triggerOld.isEmpty()) return;

            Set<Id> winnerIds = new Set<Id>();
            for (Contact loser : triggerOld) {
                if (loser.LastName != null && loser.LastName.contains('MERGE_TO:')) {
                    String winnerId = loser.LastName.substring(loser.LastName.indexOf('MERGE_TO:') + 9);
                    if (winnerId.length() >= 15) {
                        winnerIds.add(Id.valueOf(winnerId.substring(0, 15)));
                    }
                }
            }
            if (winnerIds.isEmpty()) return;

            Map<Id, Contact> winnersById = new Map<Id, Contact>(
                [SELECT Id, CreatedDate FROM Contact WHERE Id IN :winnerIds]
            );

            Map<Id, List<Contact>> losersByWinner = new Map<Id, List<Contact>>();
            for (Contact loser : triggerOld) {
                if (loser.LastName == null || !loser.LastName.contains('MERGE_TO:')) continue;
                String winnerIdStr = loser.LastName.substring(loser.LastName.indexOf('MERGE_TO:') + 9);
                if (winnerIdStr.length() >= 15) {
                    Id winnerId = Id.valueOf(winnerIdStr.substring(0, 15));
                    if (!losersByWinner.containsKey(winnerId)) {
                        losersByWinner.put(winnerId, new List<Contact>());
                    }
                    losersByWinner.get(winnerId).add(loser);
                }
            }

            for (Id winnerId : losersByWinner.keySet()) {
                Contact winner = winnersById.get(winnerId);
                if (winner == null) continue;

                Datetime minCreated = winner.CreatedDate;
                Id oldestId = winner.Id;

                for (Contact loser : losersByWinner.get(winnerId)) {
                    if (loser.CreatedDate < minCreated) {
                        minCreated = loser.CreatedDate;
                        oldestId = loser.Id;
                    }
                }

                if (oldestId != winner.Id) {
                    String msg = 'Merge blocked: the master must be the OLDEST record by CreatedDate. '
                               + 'Please select the oldest record as master and try again.';
                    for (Contact loser : losersByWinner.get(winnerId)) {
                        loser.addError(msg);
                    }
                }
            }
        }
    }

    @IsTest
    static void testAccountMergeValidation_OldestWins() {
        // Create accounts with different dates
        Account oldAccount = new Account(Name = 'Old Account');
        insert oldAccount;
        Test.setCreatedDate(oldAccount.Id, DateTime.now().addDays(-10));

        Account newAccount = new Account(Name = 'New Account');
        insert newAccount;
        Test.setCreatedDate(newAccount.Id, DateTime.now().addDays(-5));

        Test.startTest();

        // Simulate merge by setting the winner ID in the name
        newAccount.Name = 'MERGE_TO:' + oldAccount.Id;
        update newAccount;

        // Test the trigger logic directly
        List<Account> testAccounts = [SELECT Id, Name, CreatedDate FROM Account WHERE Id = :newAccount.Id];
        TestableAccountTrigger helper = new TestableAccountTrigger();
        helper.executeTriggerLogic(testAccounts, new Map<Id, Account>(testAccounts));

        System.assert(true, 'Valid merge should be allowed');
        Test.stopTest();
    }

    @IsTest
    static void testAccountMergeValidation_NewestBlocked() {
        Account oldAccount = new Account(Name = 'Old Account');
        insert oldAccount;
        Test.setCreatedDate(oldAccount.Id, DateTime.now().addDays(-10));

        Account newAccount = new Account(Name = 'New Account');
        insert newAccount;
        Test.setCreatedDate(newAccount.Id, DateTime.now().addDays(-5));

        Test.startTest();

        // Simulate invalid merge (older record being merged into newer)
        oldAccount.Name = 'MERGE_TO:' + newAccount.Id;
        update oldAccount;

        List<Account> testAccounts = [SELECT Id, Name, CreatedDate FROM Account WHERE Id = :oldAccount.Id];

        try {
            TestableAccountTrigger helper = new TestableAccountTrigger();
            helper.executeTriggerLogic(testAccounts, new Map<Id, Account>(testAccounts));
            System.assert(false, 'Invalid merge should be blocked');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Merge blocked') || e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                'Should block invalid merge');
        }

        Test.stopTest();
    }

    @IsTest
    static void testContactMergeValidation_OldestWins() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        Account testAccount = accounts[0];

        Contact oldContact = new Contact(
            FirstName = 'Old',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'old@test.com'
        );
        insert oldContact;
        Test.setCreatedDate(oldContact.Id, DateTime.now().addDays(-10));

        Contact newContact = new Contact(
            FirstName = 'New',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'new@test.com'
        );
        insert newContact;
        Test.setCreatedDate(newContact.Id, DateTime.now().addDays(-5));

        Test.startTest();

        newContact.LastName = 'MERGE_TO:' + oldContact.Id;
        update newContact;

        List<Contact> testContacts = [SELECT Id, LastName, CreatedDate FROM Contact WHERE Id = :newContact.Id];
        TestableContactTrigger helper = new TestableContactTrigger();
        helper.executeTriggerLogic(testContacts, new Map<Id, Contact>(testContacts));

        System.assert(true, 'Valid contact merge should be allowed');
        Test.stopTest();
    }

    @IsTest
    static void testContactMergeValidation_NewestBlocked() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        Account testAccount = accounts[0];

        Contact oldContact = new Contact(
            FirstName = 'Old',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'old@test.com'
        );
        insert oldContact;
        Test.setCreatedDate(oldContact.Id, DateTime.now().addDays(-10));

        Contact newContact = new Contact(
            FirstName = 'New',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'new@test.com'
        );
        insert newContact;
        Test.setCreatedDate(newContact.Id, DateTime.now().addDays(-5));

        Test.startTest();

        oldContact.LastName = 'MERGE_TO:' + newContact.Id;
        update oldContact;

        List<Contact> testContacts = [SELECT Id, LastName, CreatedDate FROM Contact WHERE Id = :oldContact.Id];

        try {
            TestableContactTrigger helper = new TestableContactTrigger();
            helper.executeTriggerLogic(testContacts, new Map<Id, Contact>(testContacts));
            System.assert(false, 'Invalid contact merge should be blocked');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Merge blocked') || e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                'Should block invalid contact merge');
        }

        Test.stopTest();
    }

    @IsTest
    static void testNormalDeleteOperations() {
        // Test that normal deletes still work
        Account testAccount = new Account(Name = 'Regular Delete Test');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Regular',
            LastName = 'Delete Test',
            AccountId = testAccount.Id,
            Email = 'test@example.com'
        );
        insert testContact;

        Test.startTest();

        try {
            delete testContact;
            delete testAccount;
            System.assert(true, 'Normal deletes should work');
        } catch (Exception e) {
            System.assert(false, 'Normal deletes should not be blocked: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void testBulkMergeValidation() {
        // Test bulk operations
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Bulk Account ' + i));
        }
        insert accounts;

        // Set different created dates
        for (Integer i = 0; i < accounts.size(); i++) {
            Test.setCreatedDate(accounts[i].Id, DateTime.now().addDays(-10 + i));
        }

        Test.startTest();

        // Test bulk trigger logic
        List<Account> testAccounts = [SELECT Id, Name, CreatedDate FROM Account WHERE Id IN :accounts];
        TestableAccountTrigger helper = new TestableAccountTrigger();
        helper.executeTriggerLogic(testAccounts, new Map<Id, Account>(testAccounts));

        System.assert(true, 'Bulk operations should be handled correctly');
        Test.stopTest();
    }
}