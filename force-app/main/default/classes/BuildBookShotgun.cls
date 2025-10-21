public class BuildBookShotgun {

    public static void shoot(String target, Integer howMany, Decimal maxVal, Decimal yearGoal) {
        Decimal totalRequired = yearGoal * howMany;
        List<Account> allAccounts = new List<Account>();
        Decimal totalAvailable = 0;

        // Keep fetching accounts until there's enough to meet the total goal
        while (true) {
            List<Account> queryResults = [
                SELECT Id, Previous_Year_Won_Amount__c, This_Year_Won_Amount__c, Open_Opportunities_Amount__c
                FROM Account 
                WHERE Owner.Name LIKE :('%' + target + '%') 
                AND Previous_Year_Won_Amount__c <= :maxVal
                AND Previous_Year_Won_Amount__c != 0
                ORDER BY Previous_Year_Won_Amount__c DESC
            ];

            totalAvailable = 0;
            allAccounts.clear();

            for (Account acc : queryResults) {
                Decimal thisYear = acc.This_Year_Won_Amount__c == null ? 0 : acc.This_Year_Won_Amount__c;
                Decimal openOpps = acc.Open_Opportunities_Amount__c == null ? 0 : acc.Open_Opportunities_Amount__c;
                if (thisYear + openOpps <= maxVal * 0.5) {
                    allAccounts.add(acc);
                    totalAvailable += acc.Previous_Year_Won_Amount__c;
                }
            }

            if (totalAvailable >= totalRequired) break;
            maxVal *= 1.1; // bump max and try again
        }

        // Categorize into tiers
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();

        for (Account acc : allAccounts) {
            Decimal amt = acc.Previous_Year_Won_Amount__c;
            if (amt >= 0.7 * maxVal) {
                tier1.add(acc);
            } else if (amt >= 0.4 * maxVal) {
                tier2.add(acc);
            } else {
                tier3.add(acc);
            }
        }

        // Shuffle all tiers
        tier1 = shuffleList(tier1);
        tier2 = shuffleList(tier2);
        tier3 = shuffleList(tier3);

        // Track how many each book can take from each tier
        Integer tier1PerBook = tier1.size() / howMany;
        Integer tier2PerBook = tier2.size() / howMany;
        Integer tier3PerBook = tier3.size() / howMany;

        Integer bookNumber = 1;
        List<Account> finalAccounts = new List<Account>();

        for (Integer i = 0; i < howMany; i++) {
            List<Account> thisBook = new List<Account>();
            Decimal bookTotal = 0;

            Decimal targetPerTier = yearGoal / 3;

            List<Account> usedFromTier1 = pullFromTier(tier1, tier1PerBook, targetPerTier, bookTotal, yearGoal);
            thisBook.addAll(usedFromTier1);
            for (Account a : usedFromTier1) bookTotal += a.Previous_Year_Won_Amount__c;

            List<Account> usedFromTier2 = pullFromTier(tier2, tier2PerBook, targetPerTier, bookTotal, yearGoal);
            thisBook.addAll(usedFromTier2);
            for (Account a : usedFromTier2) bookTotal += a.Previous_Year_Won_Amount__c;

            List<Account> usedFromTier3 = pullFromTier(tier3, tier3PerBook, targetPerTier, bookTotal, yearGoal);
            thisBook.addAll(usedFromTier3);
            for (Account a : usedFromTier3) bookTotal += a.Previous_Year_Won_Amount__c;

            // Fill shortfall from fallback tiers
            while (bookTotal < yearGoal) {
                Account filler = getNextAvailable(tier3, tier3PerBook);
                if (filler == null) filler = getNextAvailable(tier2, tier2PerBook);
                if (filler == null) filler = getNextAvailable(tier1, tier1PerBook);
                if (filler == null) break;

                thisBook.add(filler);
                bookTotal += filler.Previous_Year_Won_Amount__c;
            }

            for (Account acc : thisBook) {
                acc.put('distroNumber__c', bookNumber);
            }

            finalAccounts.addAll(thisBook);
            bookNumber++;
        }

        if (!finalAccounts.isEmpty()) {
            safeUpdateAccounts(finalAccounts);
        }
        
    }

    private static List<Account> pullFromTier(List<Account> tier, Integer perBookCap, Decimal maxAmt, Decimal currentTotal, Decimal goal) {
        List<Account> result = new List<Account>();
        Decimal subtotal = 0;
        Integer used = 0;

        while (!tier.isEmpty() && used < perBookCap && subtotal < maxAmt && currentTotal + subtotal < goal) {
            Account acc = tier.remove(0);
            subtotal += acc.Previous_Year_Won_Amount__c;
            result.add(acc);
            used++;
        }

        return result;
    }

    private static Account getNextAvailable(List<Account> tier, Integer perBookCap) {
        if (tier.isEmpty()) return null;
        return tier.remove(0);
    }

    private static List<Account> shuffleList(List<Account> inputList) {
        List<Account> shuffled = new List<Account>(inputList);
        Integer n = shuffled.size();
    
        while (n > 1) {
            Integer k = Math.mod(Math.abs(Crypto.getRandomInteger()), n);
            n--;
            Account temp = shuffled[n];
            shuffled[n] = shuffled[k];
            shuffled[k] = temp;
        }
    
        return shuffled;
    }    

    private static void safeUpdateAccounts(List<Account> accountsToUpdate) {
        Integer batchSize = 25;
        for (Integer i = 0; i < accountsToUpdate.size(); i += batchSize) {
            Integer endIndex = Math.min(i + batchSize, accountsToUpdate.size());
            List<Account> batch = new List<Account>();
            for (Integer j = i; j < endIndex; j++) {
                batch.add(accountsToUpdate[j]);
            }
    
            try {
                update batch;
            } catch (DmlException e) {
                System.debug('⚠️ Update failed for batch: ' + e.getMessage());
            }
        }
    }
    
    
}