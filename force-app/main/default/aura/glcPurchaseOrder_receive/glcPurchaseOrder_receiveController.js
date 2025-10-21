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
    onClickDeleteChild: function(component, event, helper){
        let recordId = event.target.getAttribute("data-selected-recordId");
        helper.deleteChild(component,recordId);
    },
    onClickEditChild:function(component,event,helper){
        let target = event.target;
        let recordId = target.getAttribute("data-selected-recordId");
        component.set('v.modalRecordId',recordId);
        component.set('v.showModal',true);
        helper.showSpinner(component);
    },
    onLoadModalEdit:function(component,event,helper){        
        helper.hideSpinner(component);
    },    
    editChild_onSuccess:function(component,event,helper){
        component.set('v.showModal',false);
        helper.retrievePoMoves(component);
    },
    editChild_onCancel:function(component,event,helper){
        component.set('v.showModal',false);
    },
    onClickResetLocation: function(component,event,helper){
        helper.resetLocation(component);
    },
    onClickSelectLocation:function(component,event,helper){
        helper.selectLocation(component);
    },
    onClickResetPol: function(component,event,helper){
        helper.resetPol(component);
    },
    onClickSelectPol: function(component, event, helper){
        let recordId = event.target.getAttribute("data-selected-recordId");
        helper.selectPol(component,recordId);  
    },
    onChangeWhs: function(component,event,helper){
        helper.setLocations(component);
    },
    onFocusQty: function(component,event,helper){
        component.set('v.serialNumber',null);
        component.set('v.qtyFocus',true);
    },
    onClickQtySave: function(component,event,helper){
        helper.process(component);
    },
    onClickQtyCancel: function(component,event,helper){
        component.set('v.qty',null);
        component.set('v.qtyFocus',false);
    },
    onQtyKeyPress:function(component,event,helper){
		if (event.keyCode === 13 || event.charCode === 13 || event.which === 13) {
            helper.process(component);
        }
    },

    onActiveTab_lines:function(component,event,helper){
        helper.retrievePoLines(component);
        component.set('v.activeTab','poLines');
    },
    onActiveTab_moves:function(component,event,helper){
        helper.retrievePoMoves(component);
        component.set('v.activeTab','poMoves');
    },
})