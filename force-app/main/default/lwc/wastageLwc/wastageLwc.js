import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfos } from "lightning/uiObjectInfoApi";
import SALESORDER_OBJECT from "@salesforce/schema/AcctSeedERP__Sales_Order__c";
import WASTAGE_OBJECT from "@salesforce/schema/QC_Wastage__c";
import RESPONSIBLE_FIELD from "@salesforce/schema/QC_Wastage__c.Responsible_Party__c";
import ISSUE_FIELD from "@salesforce/schema/QC_Wastage__c.Issue_Group__c";
import LOCATION_FIELD from "@salesforce/schema/QC_Wastage__c.Location__c";

import getSalesOrderRecord from "@salesforce/apex/Wastage.getSalesOrderRecord";
import getSalesOrderItemRecord from "@salesforce/apex/Wastage.getSalesOrderItemRecord";
import insertWastageRecords from "@salesforce/apex/Wastage.insertWastageRecords";
import getSalesOrderPicklist from "@salesforce/apex/Wastage.getSalesOrderPicklist";

export default class WastageLwc extends LightningElement {
    @api recordId;
    salesOrderItemObjectApiName = 'AcctSeedERP__Sales_Order_Line__c';
    @api salesOrderId;
    formDisplay = true;
    wasteObjRecordTypeId = '';
    pressNumber;
    printer;
    unloader;
    catcher;
    jobApprovedBy;
    responsible;
    issue;
    location;
    spinner = true;
    quantityNeededArray = [];
    @track wastageWrapper = {
        pressNumber: "",
        printer: "",
        unloader: "",
        catcher: "",
        jobApprovedBy: "",
        oppName : "",
        salesOrderItems: []
    };
    
    salesOrderItemObject = {
        Id: "",                    
        productSKU: "",            
        productName: "",          
        color: "",              
        quantityNeeded: 0,        
        index: 0,               
        responsibleParty: "",      
        issueGroup: "",          
        location: "",             
        issueDescription: "",       
        avoidable: false     
    };

    connectedCallback() {
        const url = new URL(window.location.href);
        const params = new URLSearchParams(url.search);
        this.salesOrderId = params.get('salesOrderId');
    }

   
   @wire(getSalesOrderRecord, {recordId : '$salesOrderId'})
    getSalesOrderId({ error, data }) {
        if (data) {
            console.log("Sales Order : " + JSON.stringify(data))
            //this.salesOrderId = data.Id;
            this.wastageWrapper.pressNumber = data.Press_Number__c;
            this.wastageWrapper.printer = data.Printer__c;
            this.wastageWrapper.unloader = data.Unloader__c;
            this.wastageWrapper.catcher = data.Catcher__c;
            this.wastageWrapper.oppName = data.AcctSeedERP__Opportunity__r.Name;
            this.wastageWrapper.jobApprovedBy = data.Job_Approved_By__c;

        } else if (error) {
            console.log(error);
        }
    }

    @wire(getSalesOrderItemRecord, {salesOrderId : '$salesOrderId'})
    getSalesOrderItemRec({ error, data }) {
        if (data) {
            let index = 0;
            data.forEach((obj) => {
                let salesOrderItemObject = {
                    Id: obj.Id,
                    productName: obj.Product_Name_2__c,
                    productSKU: obj.AcctSeedERP__Product__r.SKUID_SKU__c,
                    color: obj.AcctSeedERP__Product__r.SKUID_Color__c,
                    productSize : obj.AcctSeedERP__Product__r.SKUID_Size__c,
                    quantityNeeded: 0,
                    index: index++,
                    isrequired : false
                };
                this.wastageWrapper.salesOrderItems .push(salesOrderItemObject);
                let quantityNeeded = obj.AcctSeedERP__Quantity_Ordered__c;
                this.quantityNeededArray.push(quantityNeeded);
            });
        } else if (error) {
            console.log(error);
        }
    }

    handleSalesOrderChange(event){
        const fieldName = event.target.name;
        this.wastageWrapper = { 
            ...this.wastageWrapper, 
            [fieldName]: event.target.value 
        };
    }

    handleChange(event){
        let salesOrderItem = this.wastageWrapper.salesOrderItems;
        let val = event.target.value;
        if(event.target.dataset.id == "Responsible"){
            salesOrderItem.forEach((item) => {
                item.responsibleParty = val;
            });
        }else if(event.target.dataset.id == "Issue Group"){
            salesOrderItem.forEach((item) => {
                item.issueGroup = val;
            });
        }else if(event.target.dataset.id == "Location"){
            salesOrderItem.forEach((item) => {
                item.location = val;
            });
        }else if(event.target.dataset.id == "Issue Description"){
            salesOrderItem.forEach((item) => {
                item.issueDescription = val;
            });
        }else if(event.target.dataset.id == "Avoidable"){
            let val =  event.target.checked;
            salesOrderItem.forEach((item) => {
                item.avoidable = val;
            });
        }
    }

    handleRecordChange(event){
        const index = event.target.dataset.index; 
        const field = event.target.name; 

  
        if(field == 'quantityNeeded'){
            for(var i=0;i<this.wastageWrapper.salesOrderItems.length;i++){
                if(i == index && event.target.value > 0){
                this.wastageWrapper.salesOrderItems[i]['isrequired'] = true; 
                }
                else if(i == index && event.target.value == 0){
                    this.wastageWrapper.salesOrderItems[i]['isrequired'] = false;   
                }
            }
        }

        const value = field == "avoidable" ? event.target.checked : event.target.value;     
        this.wastageWrapper.salesOrderItems = this.wastageWrapper.salesOrderItems.map((item, idx) => {
            if (idx == index) {
                return { ...item, [field]: value };
            }
            return item;
        });
        console.log('this.wastageWrapper.salesOrderItems',JSON.stringify(this.wastageWrapper.salesOrderItems));
    }

    handleCancelClick(){
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    handleSubmitClick(){
        let wastageSalesOrderwarpper = {...this.wastageWrapper}; 
        let salesOrderItemList = wastageSalesOrderwarpper.salesOrderItems;
        let wastageRecSalesItemList = [];
        salesOrderItemList.forEach((item) => {
                if(item.quantityNeeded > 0){
                    wastageRecSalesItemList.push(item);
                }
        });
        if(wastageRecSalesItemList.length == 0){
            const evt = new ShowToastEvent({
            title: 'INFO',
            message: 'No record inserted',
            variant: 'info',
            });
            this.dispatchEvent(evt);
            return;
        }


        const inputs = this.template.querySelectorAll('.reqFields');
        let allValid = true;
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                allValid = false;
            }
        });

       if(allValid){

        wastageSalesOrderwarpper.salesOrderItems = wastageRecSalesItemList;
        insertWastageRecords({wastageRecSalesItemList : wastageSalesOrderwarpper })
        .then(result =>{
            this.formDisplay = false;
        })
        .catch(error =>{
            console.log(error);
            const evt = new ShowToastEvent({
            title: 'ERROR',
            message: error.body.message,
            variant: 'error',
            mode : 'sticky'
            });
            this.dispatchEvent(evt);
        })
        }
    }

    handleWasteAll(){
        let salesOrderItem = this.wastageWrapper.salesOrderItems;
        salesOrderItem.forEach((item) => {
            item.quantityNeeded = this.quantityNeededArray[item.index];
        });
    }

    @wire(getObjectInfos, { objectApiNames: [ WASTAGE_OBJECT ] })
    objectsInfo({error, data}){
    	if(data){
         this.wasteObjRecordTypeId =  data.results[0].result.defaultRecordTypeId; 
        }else{
         console.log(error);
        }
    }
    @wire(getSalesOrderPicklist, {})
        getSalesOrderPicklistResult({ error, data }) {
        if (data) {
            const output = Object.keys(data).reduce((acc, field) => {
            acc[field] = Object.keys(data[field]).map(key => ({
                "label": key,  
                "value": data[field][key]   
            }));
            return acc;
            }, {});
            this.pressNumber = output.Press_Number__c;
            this.printer = output.Printer__c;
            this.unloader = output.Unloader__c;
            this.catcher = output.Catcher__c;
            this.jobApprovedBy = output.Job_Approved_By__c;
            this.spinner = false;
        } else if (error) {
            console.log(error);
        }   
    }

    @wire(getPicklistValues, { recordTypeId: "$wasteObjRecordTypeId", fieldApiName: RESPONSIBLE_FIELD })
        responsiblePicklistResults({ error, data }) {
        if (data) {
            this.responsible = data.values;
        } else if (error) {
            this.responsible = undefined;
        }   
    }

    @wire(getPicklistValues, { recordTypeId: "$wasteObjRecordTypeId", fieldApiName: ISSUE_FIELD })
        issuePicklistResults({ error, data }) {
        if (data) {
            this.issue = data.values;
        } else if (error) {
            this.issue = undefined;
        }   
    }
    
    @wire(getPicklistValues, { recordTypeId: "$wasteObjRecordTypeId", fieldApiName: LOCATION_FIELD })
        locationPicklistResults({ error, data }) {
        if (data) {
            this.location = data.values;
        } else if (error) {
            this.location = undefined;
        }   
    }

}