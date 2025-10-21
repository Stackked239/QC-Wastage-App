import { LightningElement,wire,track,api} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import modal from "@salesforce/resourceUrl/Modalheightnwidth";
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSalesOrderLineInventory from '@salesforce/apex/allocateAllSOLIController.createSalesOrderLineInventory';

export default class AllocateAllSOLI extends LightningElement {
@api recordId;

@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
        console.log('recc'+this.recordId);
    }
}
connectedCallback() {
     loadStyle(this, modal);
    createSalesOrderLineInventory({ soId: this.recordId}).then( (result) => {
        console.log('result',result);
        if(result == 'NO AVAILABLE INVENTORY'){
            this.dispatchEvent(new CloseActionScreenEvent());
           const event = new ShowToastEvent({
            title: 'warning',
            variant: 'warning',
            message: result,
        });
        this.dispatchEvent(event); 
        }
        else {
        this.dispatchEvent(new CloseActionScreenEvent());
           const event = new ShowToastEvent({
            title: 'success',
            variant: 'success',
            message: result,
        });
        this.dispatchEvent(event);
    }
         
    }).catch( (error) => {
           console.log('error'+error);
    })
}

}