trigger EnforceOldestAsMaster_Account on Account (before delete) {
    if (!Trigger.isBefore || !Trigger.isDelete) return;

    // Use handler class for testability
    EnforceOldestAsMasterHandler.validateAccountMerge(Trigger.old);
}