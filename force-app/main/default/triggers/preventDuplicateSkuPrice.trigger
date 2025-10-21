trigger preventDuplicateSkuPrice on SKU_Price__c (before insert, before update) {
   preventDuplicateSkuPriceHandler.preventDuplicateInsertOrUpdate(Trigger.new);
}