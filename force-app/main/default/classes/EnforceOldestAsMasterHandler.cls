public class EnforceOldestAsMasterHandler {

    public static void validateAccountMerge(List<Account> oldAccounts) {
        // Extract the merge validation logic so it can be tested
        Set<Id> winnerIds = new Set<Id>();
        for (Account loser : oldAccounts) {
            if (loser.MasterRecordId != null) winnerIds.add(loser.MasterRecordId);
        }
        if (winnerIds.isEmpty()) return;

        // Query winners' CreatedDate
        Map<Id, Account> winnersById = new Map<Id, Account>(
            [SELECT Id, CreatedDate FROM Account WHERE Id IN :winnerIds]
        );

        // Group losers by winner
        Map<Id, List<Account>> losersByWinner = new Map<Id, List<Account>>();
        for (Account loser : oldAccounts) {
            if (loser.MasterRecordId == null) continue;
            if (!losersByWinner.containsKey(loser.MasterRecordId)) {
                losersByWinner.put(loser.MasterRecordId, new List<Account>());
            }
            losersByWinner.get(loser.MasterRecordId).add(loser);
        }

        validateMergeLogic(winnersById, losersByWinner);
    }

    public static void validateContactMerge(List<Contact> oldContacts) {
        Set<Id> winnerIds = new Set<Id>();
        for (Contact loser : oldContacts) {
            if (loser.MasterRecordId != null) winnerIds.add(loser.MasterRecordId);
        }
        if (winnerIds.isEmpty()) return;

        Map<Id, Contact> winnersById = new Map<Id, Contact>(
            [SELECT Id, CreatedDate FROM Contact WHERE Id IN :winnerIds]
        );

        Map<Id, List<Contact>> losersByWinner = new Map<Id, List<Contact>>();
        for (Contact loser : oldContacts) {
            if (loser.MasterRecordId == null) continue;
            if (!losersByWinner.containsKey(loser.MasterRecordId)) {
                losersByWinner.put(loser.MasterRecordId, new List<Contact>());
            }
            losersByWinner.get(loser.MasterRecordId).add(loser);
        }

        validateContactMergeLogic(winnersById, losersByWinner);
    }

    private static void validateMergeLogic(Map<Id, Account> winnersById, Map<Id, List<Account>> losersByWinner) {
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

            if (oldestId != winner.Id) {
                String msg = 'Merge blocked: the master must be the OLDEST record by CreatedDate. '
                           + 'Please select the oldest record as master and try again.';
                for (Account loser : losersByWinner.get(winnerId)) {
                    loser.addError(msg);
                }
            }
        }
    }

    private static void validateContactMergeLogic(Map<Id, Contact> winnersById, Map<Id, List<Contact>> losersByWinner) {
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

    // Test-only methods to simulate merge scenarios
    @TestVisible
    public static void testAccountMergeValidation(List<Account> losers, List<Account> winners) {
        // Simulate the merge scenario for testing
        Map<Id, Account> winnersById = new Map<Id, Account>();
        for (Account winner : winners) {
            winnersById.put(winner.Id, winner);
        }

        Map<Id, List<Account>> losersByWinner = new Map<Id, List<Account>>();
        for (Account loser : losers) {
            Id masterId = winners[0].Id; // Simulate master assignment
            if (!losersByWinner.containsKey(masterId)) {
                losersByWinner.put(masterId, new List<Account>());
            }
            losersByWinner.get(masterId).add(loser);
        }

        validateMergeLogic(winnersById, losersByWinner);
    }

    @TestVisible
    public static void testContactMergeValidation(List<Contact> losers, List<Contact> winners) {
        Map<Id, Contact> winnersById = new Map<Id, Contact>();
        for (Contact winner : winners) {
            winnersById.put(winner.Id, winner);
        }

        Map<Id, List<Contact>> losersByWinner = new Map<Id, List<Contact>>();
        for (Contact loser : losers) {
            Id masterId = winners[0].Id;
            if (!losersByWinner.containsKey(masterId)) {
                losersByWinner.put(masterId, new List<Contact>());
            }
            losersByWinner.get(masterId).add(loser);
        }

        validateContactMergeLogic(winnersById, losersByWinner);
    }
}