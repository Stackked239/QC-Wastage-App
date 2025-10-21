public class CustomPathController {
    
    @AuraEnabled
    public static List<wrapperClass> fetchStatus( String orderId ){
        List<wrapperClass> wrpClass = New List<wrapperClass>();
        Map<String,String> stageNameAndStatusMap = New Map<String,String>();
        Map<String,Integer> stageNameMap = New Map<String,Integer>();
        stageNameMap.put('Quote_Request',1);
        stageNameMap.put('Quote Ready',2);
        stageNameMap.put('Quote Approved',3);
        stageNameMap.put('Art Started',4);
        stageNameMap.put('Art Ready',5);
        stageNameMap.put('Art Approved',6);
        stageNameMap.put('Sizes Submitted',7);
        stageNameMap.put('Scheduled for Production',8);
        
        portal_my_order__c order = [select Id,Stage__c from portal_my_order__c where Id =: orderId ];
        String currentStage = order.Stage__c;
        Integer currentStageIndex = 0;
        
        if( stageNameMap.containsKey(currentStage) ){
            currentStageIndex = stageNameMap.get(currentStage);
        }
        
        for( String stageName : stageNameMap.KeySet() ){
            Integer stageIndex = stageNameMap.get(stageName);
            if( stageIndex > currentStageIndex ){
                wrpClass.add( New wrapperClass(stageName,'NotStarted'));  
            }else if( stageIndex < currentStageIndex ){
                wrpClass.add( New wrapperClass(stageName,'Completed')); 
            }
        }
        wrpClass.add( New wrapperClass(currentStage,'Current')); 
        system.debug('wrpClass '+wrpClass);
        return wrpClass;
    }
    
    public class wrapperClass{
        
        @AuraEnabled
        public String stageName;
        @AuraEnabled
        public String stageValue;
        
        public wrapperClass( String stageName, String stageValue ){
            this.stageName = stageName;
            this.stageValue = stageValue;
        }
        
    }
    
}