({
    init: function(component){   
        if($A.get("$Browser.formFactor") == 'DESKTOP'){
            this.focusTimerStart(component);
        }
        this.retrieveLines(component);
    },
    getParams: function(component){

        let params = {};

        params.orderId = component.get('v.recordId');

        if(component.get('v.lineId'))
            params.lineId = component.get('v.lineId');
           
        if(component.get('v.qty'))
            params.qty = Number(component.get('v.qty'));
    
        return params;
    },
    retrieveLines: function(component){

        this.showSpinner(component);
        
        var action = component.get("c.retrieveLines");
    
        action.setParams({
            orderId:      component.get('v.recordId')
        });
    
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.lines',response.getReturnValue());
            }
            else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    retrieveMoves: function(component){

        this.showSpinner(component);

        var filterId;
        if(component.get('v.lineId'))
            filterId = component.get('v.lineId');
        else 
            filterId = component.get('v.recordId');

        var action = component.get("c.retrieveMoves");
    
        action.setParams({
            filterId:      filterId
        });
    
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.moves',response.getReturnValue());
            }
            else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    validate: function(component){
        let qty = component.get('v.qty');
        if(!qty || qty < 0){
            this.showMessage(component, 'The Quantity to Transfer must be a positive number.');
            return false;
        }
        return true;
    },
    saveQty: function(component){
        if(this.validate(component)){
            this.process(component,null);
        }
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
        
        let params = this.getParams(component);
        if(barcode){
            if(uiMode == 'scan')
                params.productCode = barcode;
            else if(uiMode == 'detail')
                params.serialNumber = barcode;
        }

        let action = component.get("c.process");
        action.setParams({
            strParams:			JSON.stringify(params)
        });
       
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                
                params = JSON.parse(response.getReturnValue());

                component.set('v.lines',params.lines);
                component.set('v.moves',params.moves);
                component.set('v.uiMode','scan');

                if($A.get("$Browser.formFactor") == 'DESKTOP' && $A.get('e.force:refreshView'))
                    $A.get('e.force:refreshView').fire();

                this.reset(component);
            }
            else{
                this.showApexError(component, response.getError());
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);       
    },
    reset: function(component){
        component.set('v.qty',null);
        component.set('v.lineId',null);
    },
    resetLine: function(component){
        component.set('v.lineId',null);
        component.set('v.uiMode','scan');
        this.retrieveLines(component);
        if(component.get('v.activeTab') == 'moves')
            this.retrieveMoves(component);
    },
    selectLine: function(component,recordId){
        component.set('v.lineId',recordId);
        component.set('v.uiMode','detail');
        this.retrieveMoves(component); 
        this.focusInputQty(component);
    },
    deleteChild: function(component,recordId){

        this.showSpinner(component);
        
        var filterId;
        if(component.get('v.lineId'))
            filterId = component.get('v.lineId');
        else 
            filterId = component.get('v.recordId');

        var action = component.get("c.deleteMove"); 
        action.setParams({
            moveId:     recordId,
            filterId:   filterId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                
                component.set("v.moves", response.getReturnValue());
                
                this.retrieveLines(component);

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
    focusInputQty: function(component){
        function setFocus(){
            if(component.find('inputQty'))
                component.find('inputQty').focus();
        }
        
        //run once soon after being called
        setTimeout($A.getCallback(setFocus),200);       
    },
    focusTimerStart: function(component){
        function setFocus(){
            if(component.find('laserScanner') &&          
               component.get('v.uiMode') == 'scan'){
                    component.find('laserScanner').focus();
            }
        }
        
        //run once soon after being called
        setTimeout($A.getCallback(setFocus),100);
        
        //run periodically
        let focusTimer = setInterval($A.getCallback(setFocus),1000);
        component.set('v.focusTimer',focusTimer);
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