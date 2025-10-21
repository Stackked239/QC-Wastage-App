@isTest
private class BuildBookShotgunTest {

    @isTest
    static void testShootLogic() {
        Integer howMany = 3;
        Decimal maxVal = 10000;
        Decimal yearGoal = 7000;
        String target = 'Test User';

        // Create mock user to match Owner.Name LIKE
        User testUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        List<Account> mockAccounts = new List<Account>();

        for (Integer i = 0; i < 90; i++) {
            Decimal previousYearAmount;
            if (i < 30) {
                previousYearAmount = 2000; // Tier 3
            } else if (i < 60) {
                previousYearAmount = 5000; // Tier 2
            } else {
                previousYearAmount = 8000; // Tier 1
            }

            mockAccounts.add(new Account(
                Name = 'Mock Account ' + i,
                OwnerId = testUser.Id,
                Previous_Year_Won_Amount__c = previousYearAmount,
                This_Year_Won_Amount__c = 0,
                Open_Opportunities_Amount__c = 0
            ));
        }

        insert mockAccounts;

        Test.startTest();
        BuildBookShotgun.shoot(testUser.Name, howMany, maxVal, yearGoal);
        Test.stopTest();

        // Validate results
        List<Account> updatedAccounts = [
            SELECT Id, distroNumber__c
            FROM Account
            WHERE distroNumber__c != NULL
        ];

        System.assertEquals(true, updatedAccounts.size() > 0, 'Some accounts should be updated');

        Set<Integer> bookNumbers = new Set<Integer>();
        for (Account acc : updatedAccounts) {
            bookNumbers.add(((Decimal) acc.get('distroNumber__c')).intValue());

        }

        System.assertEquals(howMany, bookNumbers.size(), 'All books should be represented.');
    }
}