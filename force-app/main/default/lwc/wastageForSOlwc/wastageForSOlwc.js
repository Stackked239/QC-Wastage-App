import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getSalesOrderRecord from "@salesforce/apex/Wastage.getSalesOrderId";
export default class WastageForSOlwc extends LightningElement {

   @api recordId;
   salesOrderId = '';

   isLoaded = false;

    renderedCallback(){
        if(this.isLoaded) return;
        const STYLE = document.createElement("style");
        STYLE.innerText = `.uiModal--medium .modal-container{
            width: 80% !important;
            max-width: 100%;
            min-width: 480px;
            max-height: 100%;
            min-height: 480px;
        }`;
        this.template.querySelector('c-wastage-lwc').appendChild(STYLE);
        this.isLoaded = true;
    }

    @wire(getSalesOrderRecord, {oppId : '$recordId'})
    getSalesOrderId({ error, data }) {
        if (data) {
            console.log(data);
            this.salesOrderId = data;
        } else if (error) {
            console.log(error);
        }
    }

    handleCancelClick(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}