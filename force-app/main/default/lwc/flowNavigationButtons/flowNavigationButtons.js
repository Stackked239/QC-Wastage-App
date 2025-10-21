import { LightningElement,api } from 'lwc';
import {FlowNavigationBackEvent, FlowNavigationNextEvent,FlowNavigationFinishEvent} from "lightning/flowSupport";

export default class FlowNavigationButtons extends LightningElement {

  @api Next;
  @api Previous;
  @api showNextButton;
  @api showPreviousButton;

  // renderedCallback(){
  //   console.log('@@showNextButton 1::',this.showNextButton);
  //   console.log('@@showPreviousButton 1::',this.showPreviousButton);
  // }

  //  connectedCallback(){
  //   console.log('@@showNextButton::',this.showNextButton);
  //   console.log('@@showPreviousButton::',this.showPreviousButton);
  //  }

    handleNext() {

         let buttonsEvent;
          if(this.Next==='Retry' || this.Next==='Start Another Order' || this.Next === 'Finish'){
            buttonsEvent = new FlowNavigationFinishEvent();
          }else{
             buttonsEvent = new FlowNavigationNextEvent();
          }
          this.dispatchEvent(buttonsEvent);

      }
      handleBack() {
          const navigateBackEvent = new FlowNavigationBackEvent();
          this.dispatchEvent(navigateBackEvent);
      }
}