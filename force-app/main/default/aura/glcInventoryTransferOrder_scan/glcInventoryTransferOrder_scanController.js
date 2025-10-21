({
    onInit : function(component,event,helper) {
        helper.init(component);
    },
    onScanStart:function(component,event,helper){
        component.find('nativeScanner').scan();
    },
    onScanSuccess:function(component,event,helper){
        helper.scanSuccess(component,event);
    },
    goToRecord: function(component, event, helper){
        let recordId = event.target.getAttribute("data-selected-recordId");
        let replaceNavHistory = event.target.getAttribute("data-selected-replaceNavHistory") ? true : false;
        helper.goToRecord(component,recordId,replaceNavHistory);  
    },
    closeQuickAction: function(component,event,helper){
        $A.get('e.force:closeQuickAction').fire();
    },

    //select line to view details
    onClickSelectLine: function(component,event,helper){
        let recordId = event.target.getAttribute("data-selected-recordId");
        helper.selectLine(component,recordId);
    },

    //entering the quantity
    onClickSaveQty: function(component,event,helper){
        helper.saveQty(component);
    },
    onClickCancelQty: function(component,event,helper){
        helper.resetLine(component);
    },
    onClickResetLine: function(component,event,helper){
        helper.resetLine(component);
    },
    onQtyKeyPress: function(component,event,helper){
    	if (event.keyCode === 13 || event.charCode === 13 || event.which === 13){
            helper.saveQty(component); 
        }
    },

    //delete inventory movement
    onClickDeleteChild: function(component, event, helper){
        let recordId = event.target.getAttribute("data-selected-recordId");
        helper.deleteChild(component,recordId);
    },

    //sub-tabs
    onActiveTab_lines:function(component,event,helper){
        helper.retrieveLines(component);
        component.set('v.activeTab','lines');
    },
    onActiveTab_moves:function(component,event,helper){
        helper.retrieveMoves(component);
        component.set('v.activeTab','moves');
    },
})