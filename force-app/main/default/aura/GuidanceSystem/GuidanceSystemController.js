({
    doinit : function(component, event, helper) {
       
        var guideStatus = $A.get("$Label.c.Active_Community_Guide_System");
        console.log('Label Value '+guideStatus);
        component.set("v.enableCompleteGuideSystem",guideStatus);
        console.log('Enable Guide System '+guideStatus);
        
        var action = component.get("c.findAll");
        action.setCallback(this, function(response) {
            var state = response.getState();
			var result = response.getReturnValue();
            if (state == "SUCCESS" && result !=null) {
                var urlString = window.location.href;
                component.set("v.cgsList", result);
                for (let i = 0; i < result.length; i++) {                    
                    if(result[i].is_First_Message__c){
                        if(result[i].Page_Number__c == 1 && result[i].Message_No__c == 1){
                            component.set("v.ordertitle", result[i].Title__c);
                            component.set("v.ordermessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 2 && result[i].Message_No__c == 1){
                            component.set("v.pendingtitle1", result[i].Title__c);
                            component.set("v.pendingmessage1", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 3 && result[i].Message_No__c == 1){
                            component.set("v.myordertitle", result[i].Title__c);
                            component.set("v.myordermessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 4 && result[i].Message_No__c == 1){
                            component.set("v.yourprofiletitle", result[i].Title__c);
                            component.set("v.yourprofilemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 5 && result[i].Message_No__c == 1){
                            component.set("v.accounttitle", result[i].Title__c);
                            component.set("v.accountmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 6 && result[i].Message_No__c == 1){
                            component.set("v.startordertitle", result[i].Title__c);
                            component.set("v.startordermessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 7 && result[i].Message_No__c == 1){
                            component.set("v.orderdetailtitle", result[i].Title__c);
                            component.set("v.orderdetailmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 8 && result[i].Message_No__c == 1){
                            component.set("v.filetitle", result[i].Title__c);
                            component.set("v.filemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 9 && result[i].Message_No__c == 1){
                            component.set("v.completeordertitle", result[i].Title__c);
                            component.set("v.completeordermessage", result[i].Main_Message__c);
                        }
                    }
                    else if(result[i].is_Last_Message__c){
                        if(result[i].Page_Number__c == 1 && result[i].Message_No__c == 3){
                            component.set("v.hometitle", result[i].Title__c);
                            component.set("v.homemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 2 && result[i].Message_No__c == 5){
                            component.set("v.previoustitle", result[i].Title__c);
                            component.set("v.previousmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 3 && result[i].Message_No__c == 6){
                            component.set("v.totalpricetitle", result[i].Title__c);
                            component.set("v.totalpricemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 7 && result[i].Message_No__c == 8){
                            component.set("v.shippingtitle", result[i].Title__c);
                            component.set("v.shippingmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 8 && result[i].Message_No__c == 4){
                            component.set("v.commenttitle", result[i].Title__c);
                            component.set("v.commentmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 9 && result[i].Message_No__c == 3){
                            component.set("v.trackingnotitle", result[i].Title__c);
                            component.set("v.trackingnomessage", result[i].Main_Message__c);
                        }
                    }
                    else{
                        if(result[i].Page_Number__c == 1 && result[i].Message_No__c == 2){
                            component.set("v.supporttitle", result[i].Title__c);
                            component.set("v.supportmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 2 && result[i].Message_No__c == 2){
                            component.set("v.pendingtitle2", result[i].Title__c);
                            component.set("v.pendingmessage2", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 2 && result[i].Message_No__c == 3){
                            component.set("v.revisiontitle1", result[i].Title__c);
                            component.set("v.revisionmessage1", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 2 && result[i].Message_No__c == 4){
                            component.set("v.revisiontitle2", result[i].Title__c);
                            component.set("v.revisionmessage2", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 3 && result[i].Message_No__c == 2){
                            component.set("v.stagetitle", result[i].Title__c);
                            component.set("v.stagemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 3 && result[i].Message_No__c == 3){
                            component.set("v.submitbytitle", result[i].Title__c);
                            component.set("v.submitbymessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 3 && result[i].Message_No__c == 4){
                            component.set("v.inhandsdatetitle", result[i].Title__c);
                            component.set("v.inhandsdatemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 3 && result[i].Message_No__c == 5){
                            component.set("v.balanceduetitle", result[i].Title__c);
                            component.set("v.balanceduemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 7 && result[i].Message_No__c == 2){
                            component.set("v.stagebartitle", result[i].Title__c);
                            component.set("v.stagebarmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 7 && result[i].Message_No__c == 3){
                            component.set("v.producttitle", result[i].Title__c);
                            component.set("v.productmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 7 && result[i].Message_No__c == 4){
                            component.set("v.colortitle", result[i].Title__c);
                            component.set("v.colormessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 7 && result[i].Message_No__c == 5){
                            component.set("v.quantitytitle", result[i].Title__c);
                            component.set("v.quantitymessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 7 && result[i].Message_No__c == 6){
                            component.set("v.pricetitle", result[i].Title__c);
                            component.set("v.pricemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 7 && result[i].Message_No__c == 7){
                            component.set("v.invoicetitle", result[i].Title__c);
                            component.set("v.invoicemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 8 && result[i].Message_No__c == 2){
                            component.set("v.imagetitle", result[i].Title__c);
                            component.set("v.imagemessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 8 && result[i].Message_No__c == 3){
                            component.set("v.revisiondetailtitle", result[i].Title__c);
                            component.set("v.revisiondetailmessage", result[i].Main_Message__c);
                        }
                        if(result[i].Page_Number__c == 9 && result[i].Message_No__c == 2){
                            component.set("v.completepricetitle", result[i].Title__c);
                            component.set("v.completepricemessage", result[i].Main_Message__c);
                        }                        
                        if(result[i].Page_Number__c == 10 && result[i].Message_No__c == 1){
                            component.set("v.confirmtitle", result[i].Title__c);
                            component.set("v.confirmmessage", result[i].Main_Message__c);
                        }
                    }
                }
                if(urlString.includes('art-proofs')){
                    console.log('url : '+urlString);
                    component.set("v.artproofs",true);
                    component.set("v.pending1",true);
                }
                else if(urlString.includes('open-orders')){
                    component.set("v.openorders",true);
                    component.set("v.myorders",true);
                }
                else if(urlString.includes('profile')){
                    component.set("v.yourprofile",true);
                    component.set("v.profilepage",true);
                }
                else if(urlString.includes('comm-my-account')){
                    component.set("v.account",true);
                    component.set("v.accountpage",true);
                }
                else if(urlString.includes('start-order')){
                    component.set("v.startorder",true);
                    component.set("v.startorderpage",true);
                }
                else if(urlString.includes('portal-my-order')){
                    component.set("v.myorderpage",true);
                    component.set("v.myorderdetail",true);
                }
                else if(urlString.includes('art-proof-detail') && urlString.includes('Id=')){
                    component.set("v.revisionpage",true);
                    component.set("v.file",true);
                }
                else if(urlString.includes('completed-orders')){
                    component.set("v.completeorderpage",true);
                    component.set("v.completemyorder",true);
                }
                else{
                    component.set("v.order",true);
                    component.set("v.homepage",true);                   
             	}                      
            }
            else if (state == "ERROR") {
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
            else if(result == null){
                console.log("Enable Walkthrough from user profile : "+result);                
            }
        });
        $A.enqueueAction(action);
    },
   
    NextPopup : function(component, event, helper) {
        if(component.get("v.order")){
            component.set("v.order",false);
            component.set("v.support",true);     
        }
        else if(component.get("v.support")){
            component.set("v.support",false);
            component.set("v.home",true);
        }
        
        //For Art Proofing window
        if(component.get("v.pending1")){
            component.set("v.pending1",false);
            component.set("v.pending2",true);     
        }
        else if(component.get("v.pending2")){
            component.set("v.pending2",false);
            component.set("v.revision1",true);
        }
        else if(component.get("v.revision1")){
            component.set("v.revision1",false);
            component.set("v.revision2",true);
        }
        else if(component.get("v.revision2")){
            component.set("v.revision2",false);
            component.set("v.previous",true);
        }
        
        //For Open Orders window
        if(component.get("v.myorders")){
            component.set("v.myorders",false);
            component.set("v.stage",true);     
        }
        else if(component.get("v.stage")){
            component.set("v.stage",false);
            component.set("v.submitby",true);
        }
        else if(component.get("v.submitby")){
            component.set("v.submitby",false);
            component.set("v.inhandsdate",true);
        }
        else if(component.get("v.inhandsdate")){
            component.set("v.inhandsdate",false);
            component.set("v.balancedue",true);
        }
        else if(component.get("v.balancedue")){
            component.set("v.balancedue",false);
            component.set("v.totalprice",true);
        }
        
        
        //For My Order window
        if(component.get("v.myorderdetail")){
            component.set("v.myorderdetail",false);
            component.set("v.stagebar",true);     
        }
        else if(component.get("v.stagebar")){
            component.set("v.stagebar",false);
            component.set("v.productname",true);
        }
        else if(component.get("v.productname")){
            component.set("v.productname",false);
            component.set("v.color",true);
        }
        else if(component.get("v.color")){
            component.set("v.color",false);
            component.set("v.quantity",true);
        }
        else if(component.get("v.quantity")){
            component.set("v.quantity",false);
            component.set("v.priceperitem",true);
        }
        else if(component.get("v.priceperitem")){
            component.set("v.priceperitem",false);
            component.set("v.invoice",true);
        }
        else if(component.get("v.invoice")){
            component.set("v.invoice",false);
            component.set("v.shippingdetails",true);
        }
        
        //For In Revision Art Proof Detail window
        if(component.get("v.file")){
            component.set("v.file",false);
            component.set("v.image",true);     
        }
        else if(component.get("v.image")){
            component.set("v.image",false);
            component.set("v.revisiondetail",true);
        }
        else if(component.get("v.revisiondetail")){
            component.set("v.revisiondetail",false);
            component.set("v.commentsection",true);
        }
        
        //For Completed Orders window
        if(component.get("v.completemyorder")){
            component.set("v.completemyorder",false);
            component.set("v.completetotalprice",true);     
        }
        else if(component.get("v.completetotalprice")){
            component.set("v.completetotalprice",false);
            component.set("v.trackingno",true);
        }
    },
    
    PreviousPopup : function(component, event, helper) {
        if(component.get("v.home")){
            component.set("v.home",false);
            component.set("v.support",true);     
        }
        else if(component.get("v.support")){
            component.set("v.support",false);
            component.set("v.order",true);
        }
        
        //For Art Proofing window
        if(component.get("v.previous")){
            component.set("v.previous",false);
            component.set("v.revision2",true);     
        }
        else if(component.get("v.revision2")){
            component.set("v.revision2",false);
            component.set("v.revision1",true);
        }
        else if(component.get("v.revision1")){
            component.set("v.revision1",false);
            component.set("v.pending2",true);
        }
        else if(component.get("v.pending2")){
            component.set("v.pending2",false);
            component.set("v.pending1",true);
        }
        
        //For Open Orders window
        if(component.get("v.totalprice")){
            component.set("v.totalprice",false);
            component.set("v.balancedue",true);     
        }
        else if(component.get("v.balancedue")){
            component.set("v.balancedue",false);
            component.set("v.inhandsdate",true);
        }
        else if(component.get("v.inhandsdate")){
            component.set("v.inhandsdate",false);
            component.set("v.submitby",true);
        }
        else if(component.get("v.submitby")){
            component.set("v.submitby",false);
            component.set("v.stage",true);
        }
        else if(component.get("v.stage")){
            component.set("v.stage",false);
            component.set("v.myorders",true);
        }
        
        //For My Order window
        if(component.get("v.shippingdetails")){
            component.set("v.shippingdetails",false);
            component.set("v.invoice",true);     
        }
        else if(component.get("v.invoice")){
            component.set("v.invoice",false);
            component.set("v.priceperitem",true);
        }
        else if(component.get("v.priceperitem")){
            component.set("v.priceperitem",false);
            component.set("v.quantity",true);
        }
        else if(component.get("v.quantity")){
            component.set("v.quantity",false);
            component.set("v.color",true);
        }
        else if(component.get("v.color")){
            component.set("v.color",false);
            component.set("v.productname",true);
        }
        else if(component.get("v.productname")){
            component.set("v.productname",false);
            component.set("v.stagebar",true);
        }
        else if(component.get("v.stagebar")){
            component.set("v.stagebar",false);
            component.set("v.myorderdetail",true);
        }
        
        //For In Revision Art Proof Detail window
        if(component.get("v.commentsection")){
            component.set("v.commentsection",false);
            component.set("v.revisiondetail",true);     
        }
        else if(component.get("v.revisiondetail")){
            component.set("v.revisiondetail",false);
            component.set("v.image",true);
        }
        else if(component.get("v.image")){
            component.set("v.image",false);
            component.set("v.file",true);
        }
        
        //For Completed Orders window
        if(component.get("v.trackingno")){
            component.set("v.trackingno",false);
            component.set("v.completetotalprice",true);     
        }
        else if(component.get("v.completetotalprice")){
            component.set("v.completetotalprice",false);
            component.set("v.completemyorder",true);
        }
    },

    cancelMethod : function(component, event, helper) {
        if(component.get("v.order")){
            component.set("v.order",false);
            component.set("v.confirmation",true);     
        }
        else if(component.get("v.support")){
            component.set("v.support",false);
            component.set("v.confirmation",true); 
        }
        else if(component.get("v.home")){
            component.set("v.home",false);
            component.set("v.confirmation",true); 
        }
        
        //For Art Proofing window
        if(component.get("v.pending1")){
            component.set("v.pending1",false);
            component.set("v.confirmation",true);      
        }
        else if(component.get("v.pending2")){
            component.set("v.pending2",false);
            component.set("v.confirmation",true); 
        }
        else if(component.get("v.revision1")){
            component.set("v.revision1",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.revision2")){
            component.set("v.revision2",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.previous")){
            component.set("v.previous",false);
            component.set("v.confirmation",true);
        }
        
        //For Open Orders window
        if(component.get("v.myorders")){
            component.set("v.myorders",false);
            component.set("v.confirmation",true);     
        }
        else if(component.get("v.stage")){
            component.set("v.stage",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.submitby")){
            component.set("v.submitby",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.inhandsdate")){
            component.set("v.inhandsdate",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.balancedue")){
            component.set("v.balancedue",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.totalprice")){
            component.set("v.totalprice",false);
            component.set("v.confirmation",true);     
        }       
        
        //For My Order window
        if(component.get("v.myorderdetail")){
            component.set("v.myorderdetail",false);
            component.set("v.confirmation",true);     
        }
        else if(component.get("v.stagebar")){
            component.set("v.stagebar",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.productname")){
            component.set("v.productname",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.color")){
            component.set("v.color",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.quantity")){
            component.set("v.quantity",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.priceperitem")){
            component.set("v.priceperitem",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.invoice")){
            component.set("v.invoice",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.shippingdetails")){
            component.set("v.shippingdetails",false);
            component.set("v.confirmation",true);
        }
         
        //For Start Order window
        if(component.get("v.startorder")){
            component.set("v.startorder",false);
            component.set("v.confirmation",true);
        }
        
        //For Profile window
        if(component.get("v.yourprofile")){
            component.set("v.yourprofile",false);
            component.set("v.confirmation",true);
        }
        
        //For Account window
        if(component.get("v.account")){
            component.set("v.account",false);
            component.set("v.confirmation",true);
        }
        
        //For In Revision Art Proof Detail window
        if(component.get("v.file")){
            component.set("v.file",false);
            component.set("v.confirmation",true);     
        }
        else if(component.get("v.image")){
            component.set("v.image",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.revisiondetail")){
            component.set("v.revisiondetail",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.commentsection")){
            component.set("v.commentsection",false);
            component.set("v.confirmation",true);
        }
        
        //For Completed Orders window
        if(component.get("v.completemyorder")){
            component.set("v.completemyorder",false);
            component.set("v.confirmation",true);     
        }
        else if(component.get("v.completetotalprice")){
            component.set("v.completetotalprice",false);
            component.set("v.confirmation",true);
        }
        else if(component.get("v.trackingno")){
            component.set("v.trackingno",false);
            component.set("v.confirmation",true);
        }
        
        //For comfirmation popup
        if(component.get("v.confirmation")){
            var cmpTarget = component.find('confirmId');
            if(component.get("v.homepage")){
                $A.util.addClass(cmpTarget, 'homePage');                 
            }
            if(component.get("v.artproofs") || component.get("v.myorderpage") || component.get("v.revisionpage")){
                $A.util.addClass(cmpTarget, 'artProof'); 
            }
            if(component.get("v.openorders") || component.get("v.completeorderpage")){
                $A.util.addClass(cmpTarget, 'conorderPage'); 
            } 
            if(component.get("v.startorderpage") || component.get("v.profilepage") || component.get("v.accountpage")){
                $A.util.addClass(cmpTarget, 'startProAccPage'); 
            }
        }
    },
    
    confirmClose : function(component, event, helper) {
        component.set("v.confirmation",false);
    },
    
    confirmCloseCallout : function(component, event, helper) {
    	component.set("v.confirmation", false);
        var action = component.get("c.hideWalkthrough");
        action.setCallback(this, function(response) {
            var state = response.getState();
			var toastEvent = $A.get("e.force:showToast");                
            if (state == "SUCCESS") {
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Walkthrough Guide has been successfully hidden.",
                    "type": "success"
                });                
            }
            else if (state == "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error message: " + errors[0].message,
                            "type": "success"
                        });
                    }
                } 
                else {
                    console.log("Unknown error");
                }
            }
            toastEvent.fire();
        });
        $A.enqueueAction(action);        
    },
    
    confirmClose : function(component, event, helper) {
        component.set("v.order",false);     
        component.set("v.support",false); 
        component.set("v.home",false); 
        
        component.set("v.pending1",false);      
        component.set("v.pending2",false); 
        component.set("v.revision1",false);
        component.set("v.revision2",false);
        component.set("v.previous",false);
        
        component.set("v.myorders",false);     
        component.set("v.stage",false);
        component.set("v.submitby",false);
        component.set("v.inhandsdate",false);
        component.set("v.balancedue",false);
        component.set("v.totalprice",false);   
        
        component.set("v.myorderdetail",false);     
        component.set("v.stagebar",false);
        component.set("v.productname",false);
        component.set("v.color",false);
        component.set("v.quantity",false);
        component.set("v.priceperitem",false);
        component.set("v.invoice",false);
        component.set("v.shippingdetails",false);
        
        component.set("v.startorder",false);
        component.set("v.yourprofile",false);
        component.set("v.account",false);
        
        component.set("v.file",false);    
        component.set("v.image",false);
        component.set("v.revisiondetail",false);
        component.set("v.commentsection",false);
        
        component.set("v.completemyorder",false);
        component.set("v.completetotalprice",false);
        component.set("v.trackingno",false);
        
        component.set("v.confirmation", false);
    }
})