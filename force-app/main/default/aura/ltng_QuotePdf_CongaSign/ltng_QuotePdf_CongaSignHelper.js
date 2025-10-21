({
	saveFile : function(component,event,helper) {
        console.log('hi');
        var action = component.get("c.savePdf");
        action.setParams({ 'recordId' : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var newDate = new Date('01 January 2050 14:00 EST');
                var isoDate = newDate.toISOString();
                
                var wrapper = response.getReturnValue();
                
                if(wrapper.hasOwnProperty('isSuccess') && wrapper.isSuccess==true){
                    var contactId =  wrapper.QuoteRecord.hasOwnProperty('Contact_Id__c') ? wrapper.QuoteRecord.Contact_Id__c : '';
                    console.log('contactId',contactId);
                    
                    let urlRecord = new URL("https://sundaycool.secure.force.com/vfp_CongaSignRejectForm");  
                    let emailmsg = 'TO REJECT THE QUOTE PLEASE CLICK HERE:'+'\n'+urlRecord+'?Id='+component.get("v.recordId");
                    
                    var contentDocId = wrapper.hasOwnProperty('contentDocId') ? wrapper.contentDocId : '';
                    window.location.href = '/apex/APXT_CongaSign__apxt_sendForSignature?id=' +component.get("v.recordId")+ '&recipient1=' +contactId + '&documentId='+contentDocId+ '&expireOn='+isoDate+ '&emailMessage='+emailmsg; 
                }
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})