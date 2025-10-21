({
    doInit : function(component, event, helper) {
	var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse'+JSON.stringify(storeResponse))
                LiveChatWidget.call("set_session_variables", {
                    "Name" : storeResponse[0].Name,
                    "Email" : storeResponse[0].Email
                }
                );
                 
                console.log('After setting parameters');
            }
        });
        $A.enqueueAction(action);
	},
    
	afterScriptsLoaded : function(component, event, helper) {
              
    
       
      console.log('Script Loaded after');

	}
})