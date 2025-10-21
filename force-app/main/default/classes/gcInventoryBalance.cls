public without sharing class gcInventoryBalance {

    public class gcException extends Exception{}
    
    public static Id findOrCreateBalance(Id idProduct, Id idLocation){
        return findOrCreateBalance(idProduct,idLocation,retrieveLedgerId());
    }

	public static Id findOrCreateBalance(Id idProduct, Id idLocation, Id idLedger){

		AcctSeedERP__Inventory_Balance__c bal;
		
        for(AcctSeedERP__Inventory_Balance__c b : 
				[SELECT Id
				 FROM AcctSeedERP__Inventory_Balance__c
				 WHERE AcctSeedERP__Product__c = :idProduct
				   AND AcctSeedERP__Location__c = :idLocation
                   AND AcctSeedERP__Ledger__c = :idLedger
				 ORDER BY Id
				 LIMIT 1])
		{
			bal = b;
		}

		if(bal == null){
            
            Id idWarehouse;

            for(AcctSeedERP__Location__c locx : [
                SELECT Id,
                        AcctSeedERP__Warehouse__c
                FROM AcctSeedERP__Location__c
                WHERE Id =:idLocation
            ]){
                idWarehouse = locx.AcctSeedERP__Warehouse__c;
            }            
			bal = new AcctSeedERP__Inventory_Balance__c(
				AcctSeedERP__Product__c = idProduct,
				AcctSeedERP__Warehouse__c = idWarehouse,
                AcctSeedERP__Location__c = idLocation,
                AcctSeedERP__Ledger__c = idLedger
            );

			try{
                insert bal;
            }catch(Exception e){
                throw new gcException('Error when inserting new inventory balance: '+e.getMessage());
            }
		}        

		return bal.Id;
	}
    
    public static Id retrieveLedgerId(){
        for(AcctSeed__Ledger__c l : [
            SELECT Id   
            FROM AcctSeed__Ledger__c 
            WHERE AcctSeed__Type__c = 'Transactional'
            ORDER BY CreatedDate, Id 
            LIMIT 1
        ]){
            return l.Id;
        }
        throw new gcException('A Ledger of type Transactional does not exist.');
    }
}