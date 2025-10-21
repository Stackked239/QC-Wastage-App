({
    init: function(component){   

        this.setParentId(component);
        
        if($A.get("$Browser.formFactor") == 'DESKTOP'){
            this.focusTimerStart(component);
        }

        this.reloadRecords(component);

        this.retrievePoLines(component);
        
        this.retrieveLocationData(component);
    },
    setParentId: function(component){
        if(component.get('v.recordId')){
            component.set('v.poId',component.get('v.recordId'));
        }
    },
    reloadRecords: function(component){
        if(component.get('v.poId'))
            component.find('recordData_po').reloadRecord(true);
        else
            component.set('v.po',null);
    },
    getParams: function(component){

        let params = {};

        //params.action = component.get('v.action');

        params.poId = component.get('v.poId');

        if(component.get('v.poLineId'))
            params.poLineId = component.get('v.poLineId');

        if(component.get('v.locId'))
            params.locId = component.get('v.locId');
        if(component.get('v.whsId'))
            params.whsId = component.get('v.whsId');
        
        if(component.get('v.qty') != null)
            params.qty = component.get('v.qty');
    
        return params;
    },
    retrievePoLines: function(component){
    
        this.showSpinner(component);
        
        var action = component.get("c.retrievePoLines");

        action.setParams({
            poId:   component.get('v.poId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.poLines", response.getReturnValue());
            }
            else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
            $A.util.removeClass(component.find("myBody"), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    retrievePoMoves: function(component){

        var filterId;
        if(component.get('v.poLineId'))
            filterId = component.get('v.poLineId');
        else 
            filterId = component.get('v.poId');

        this.showSpinner(component);
        
        var action = component.get("c.retrievePoMoves");

        action.setParams({
            filterId:   filterId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.poMoves", response.getReturnValue());
            }
            else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
            $A.util.removeClass(component.find("myBody"), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    setLocations: function(component){
        let whsId = component.get('v.whsId');
        let mapLocations = component.get('v.mapLocations');
        let locations = mapLocations[whsId];
        component.set('v.locOptions',locations);
        component.set('v.locId',locations[0].Id);
    },
    retrieveLocationData: function(component){
        this.showSpinner(component);
        
        var action = component.get("c.retrieveLocationData");

        action.setParams({
            poId:   component.get('v.poId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){

                let locationData = response.getReturnValue();

                let whsOptions = locationData.whsOptions;
                component.set('v.whsOptions',whsOptions);

                let mapLocations = locationData.mapLocations;
                component.set('v.mapLocations',locationData.mapLocations);

                if(locationData.lastLocation && locationData.lastLocation.Id != null){
                    let whsId = locationData.lastLocation.AcctSeedERP__Warehouse__c;
                    let locId = locationData.lastLocation.Id;

                    component.set('v.whsId',whsId);
                    component.set('v.locOptions',mapLocations[whsId]);
                    component.set('v.locId',locId);
                }else{
                    component.set('v.whsId',whsOptions[0].Id);
                    this.setLocations(component);
                }
            }
            else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    deleteChild: function(component,recordId){
    
        this.showSpinner(component);
        
        var action = component.get("c.deleteChild"); 

        var uiMode = component.get('v.uiMode')

        action.setParams({
            recordId:   recordId,
            parentId:   (uiMode == 'scan' ? component.get('v.poId') : component.get('v.poLineId'))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.poMoves", response.getReturnValue());
                this.retrievePoLines(component);
                if($A.get("$Browser.formFactor") == 'DESKTOP' && $A.get('e.force:refreshView'))
                    $A.get('e.force:refreshView').fire();
            }
            else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    resetLocation: function(component){
        component.set('v.uiMode','selectLocation');
    },
    selectLocation: function(component){
        if(component.get('v.poLineId') != null)
            component.set('v.uiMode','detail');
        else 
            component.set('v.uiMode','scan');
    },
    resetPol: function(component){
        component.set('v.poLineId',null);
        component.set('v.uiMode','scan');
        this.retrievePoLines(component);
        if(component.get('v.activeTab') == 'poMoves')
            this.retrievePoMoves(component);
    },
    selectPol: function(component,recordId){
        component.set('v.poLineId',recordId);
        component.set('v.uiMode','detail');
        this.retrievePoMoves(component); 
    },
    scanSuccess: function(component,event){
        let result  = event ? event.getParam("result") : null;
        let success = event ? event.getParam("success") : null;
        let barcode = ((success && result && result[0]) ? result[0].data : null);
        this.process(component,barcode);    
    },
    process: function(component,barcode){

        this.showSpinner(component);
        
        let uiMode = component.get('v.uiMode');

        let action = component.get("c.process");

        let params = this.getParams(component);

        if(barcode){
            if(uiMode == 'scan')
                params.productCode = barcode;
            else if(uiMode == 'detail')
                params.serialNumber = barcode;
        }
        
        if(component.get('v.rapidMode') || uiMode == 'detail')
            params.action = 'createPoMove';
        else 
            params.action = 'selectPoLine';

        action.setParams({
            strParams:			JSON.stringify(params)
        });
       
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){

                let params = JSON.parse(response.getReturnValue());
                component.set('v.poMoves',params.poMoves);
                component.set('v.poLines',params.poLines);

                if(params.action == 'selectPoLine'){
                    component.set('v.poLineId',params.poLineId);
                    component.set('v.uiMode','detail');
                }else if(params.action == 'createPoMove'){
                    component.set('v.poLineId',null);
                    component.set('v.uiMode','scan');
                    if($A.get("$Browser.formFactor") == 'DESKTOP' && $A.get('e.force:refreshView'))
                        $A.get('e.force:refreshView').fire();                    
                }

                component.set('v.qty',null);
                //component.set('v.qtyFocus',false);
            }
            else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);       
    },
    goToRecord: function(component, recordId, replaceNavHistory){

        this.showSpinner(component);
        component.find('navService').navigate({
            "type":"standard__recordPage",
            "attributes":{
                "recordId":recordId,
                "actionName":"view"
            }
        });
    },  
    focusTimerStart: function(component){
        function setFocus(){
            let uiMode = component.get('v.uiMode');
            if(uiMode == 'scan' && 
                component.find('laserScanner_productCode') && 
                component.get('v.showModal') != true){
                    component.find('laserScanner_productCode').focus();
            }
            else if(uiMode == 'detail' &&
                    component.find('laserScanner_serialNumber') &&
                    component.get('v.showModal') != true && 
                    component.get('v.qtyFocus') != true){
                    component.find('laserScanner_serialNumber').focus();
            }
        }
        
        //run once soon after being called
        setTimeout($A.getCallback(setFocus),100);
        
        //run periodically
        let focusTimer = setInterval($A.getCallback(setFocus),1000);
        component.set('v.focusTimer',focusTimer);
    },
    focusTimerStop: function(component){
        clearInterval(component.get('v.focusTimer'));
    },
    showSpinner: function (component){
        let spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component){
        let spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    hideMessage: function(component){
        $A.util.removeClass(cmp.find('myToast'), "slds-show");
        $A.util.addClass(cmp.find('myToast'), "slds-hide");		
    },
    showMessage: function (cmp, message){

        let showToastEvent = $A.get("e.force:showToast");
        showToastEvent.setParams({
            type: 'error',
            message: message
        });
        showToastEvent.fire();
    },
    showApexError: function(cmp, errors){
        console.log(JSON.stringify(errors));
        if (!(errors && errors.length)) return;
    
        let messages = [];
    
        for (let i=0; i < errors.length; i++) {
            if (errors[i].message) {
                messages.push(errors[i].message);
            }
    
            if (errors[i].pageErrors && errors[i].pageErrors.length) {
                for (let j = 0; j < errors[i].pageErrors.length; j++) {
                    messages.push(errors[i].pageErrors[j].message);
                }
            }
        }
    
        if (messages.length)
            this.showMessage(cmp, messages.join('\n---\n'));
    }
})