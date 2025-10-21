trigger EnforceOldestAsMaster_Contact on Contact (before delete) {
    if (!Trigger.isBefore || !Trigger.isDelete) return;

    // Use handler class for testability
    EnforceOldestAsMasterHandler.validateContactMerge(Trigger.old);
}