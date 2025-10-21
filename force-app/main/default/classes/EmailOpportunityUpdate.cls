/**************************************************************************************************
* Class Name	: EmailOpportunityUpdate
* Author		: Pranav
* Date: 		: 26-May-2022
* group			: Wakencode
* Description	: This class is handling the inbound mails and Updating the Opprtunity based on the mail Subject. 
* Test Class 	: EmailOpportunityUpdate_Test
**************************************************************************************************/

public class EmailOpportunityUpdate implements Messaging.InboundEmailHandler {
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String oppNum= '';
        String [] texts = email.subject.replace('Re:','').replace('RE:','').replace('Fwd:','').replace('FW:','').trim().split(' ');
        
        //Subject - 102634 Has Been Approved 
        if(email.subject.containsIgnoreCase('has been approved') || email.subject.containsIgnoreCase('stage 1 has started')){
            oppNum = texts[0] + '-';
        }
        //Subject - Aaron Talbott Marked 100947 Not Approved 
        else if(email.subject.containsIgnoreCase('not approved')){
            oppNum = texts[texts.size()-3] + '-';
        }
        //Subject - There Are New Comments On 102755
        else if(email.subject.containsIgnoreCase('new comments')){
            oppNum = texts[texts.size()-1] + '-'; 
        }
        
        
        try {
            Opportunity opp = new Opportunity();
        	
            List<Opportunity> oppList = [SELECT Id, Name, Opportunity_Number__c, Ashore_Approved__c, Ashore_Revision__c From Opportunity Where Opportunity_Number__c =:oppNum];
            if(oppList.size()>0){
                opp = oppList[0];
                
                if(email.subject.containsIgnoreCase('has been approved')){
                    opp.Ashore_Approved__c = true;
                }           
                else{
                    opp.Ashore_Revision__c = true;
                }
                
                if(email.subject.containsIgnoreCase('stage 1 has started')){
                    opp.Ashore_Approved__c = false;
                    opp.Ashore_Revision__c = false;
                }           
                
                update opp;   
                System.debug('opp : '+opp);
                result.success = true;
            }
            else{
                result.success = false;
                result.message = 'No opportunity found';
            }
                      
        }
        catch (Exception e) {
            result.success = false;
            result.message = e.getMessage();
        }
        System.debug('result : '+result);
        
        return result;
    }
}