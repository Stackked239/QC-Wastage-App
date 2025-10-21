({
    saveAndRedirect : function(component, event, helper) {
        helper.saveFile(component,event,helper);		
    },
    cancel : function(component,event,helper){
          var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})