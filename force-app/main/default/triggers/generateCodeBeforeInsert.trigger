trigger generateCodeBeforeInsert on Discount_Code__c (before insert) {
    for (Discount_Code__c dc : Trigger.new) {
        String prefix = dc.Name != null ? dc.Name : '';
        String randomCode;
        Boolean isUnique = false;
        Integer attempts = 0;
        final Integer maxAttempts = 5;

        while (!isUnique && attempts < maxAttempts) {
            randomCode = GenerateCodeHelper.generateRandomCode(5);
            String fullCode = prefix + randomCode;

            Integer existingCodes = [SELECT COUNT() FROM Discount_Code__c WHERE Name = :fullCode];

            if (existingCodes == 0) { 
                dc.Name = fullCode;
                isUnique = true;
            } else {
                attempts++;
            }
        }

        if (!isUnique) {
            dc.addError('Unable to generate a unique discount code after ' + maxAttempts + ' attempts.');
        }
    }
}