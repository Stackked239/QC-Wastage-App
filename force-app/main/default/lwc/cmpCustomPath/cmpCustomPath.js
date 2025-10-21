import { LightningElement, track,api,wire } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import fetchStatus from '@salesforce/apex/CustomPathController.fetchStatus';

export default class ProgressBarDemoInLWC extends LightningElement {
    
    QuoteRequestprogress = false;
    QuoteReadyprogress = false;
    QuoteApprovedprogress = false;
    ArtStartedprogress = false;
    ArtReadyprogress = false;
    ArtApprovedprogress = false;
    SizeSubmittedprogress = false;
    ScheduledforProductionprogress = false;


    QuoteRequestCurrent = false;
    QuoteReadyCurrent = false;
    QuoteApprovedCurrent = false;
    ArtStartedCurrent = false;
    ArtReadyCurrent = false;
    ArtApprovedCurrent = false;
    SizeSubmittedCurrent = false;
    ScheduledforProductionCurrent = false;

    QuoteRequestNotStarted = false;
    QuoteReadyNotStarted = false;
    QuoteApprovedNotStarted = false;
    ArtStartedNotStarted = false;
    ArtReadyNotStarted = false;
    ArtApprovedNotStarted = false;
    SizeSubmittedNotStarted = false;
    ScheduledforProductionNotStarted = false;


    @api recordId;
    connectedCallback() {
    console.log('this.recordId ',this.recordId);
      fetchStatus({ orderId : this.recordId }).then( (result) => {
          for( var i=0; i< result.length;i++ ){
              if( result[i].stageName == 'Quote_Request' ){
                  if( result[i].stageValue == 'Completed' ){
                      this.QuoteRequestprogress = true;
                  }else if( result[i].stageValue == 'Current' ){
                      this.QuoteRequestCurrent = true;
                  }else if( result[i].stageValue == 'NotStarted' ){
                      this.QuoteRequestNotStarted = true;
                  }
              }else if( result[i].stageName == 'Quote Ready' ){
                  if( result[i].stageValue == 'Completed' ){
                      this.QuoteReadyprogress = true;
                  }else if( result[i].stageValue == 'Current' ){
                      this.QuoteReadyCurrent = true;
                  }else if( result[i].stageValue == 'NotStarted' ){
                      this.QuoteReadyNotStarted = true;
                  }
              }else if( result[i].stageName == 'Quote Approved' ){
                  if( result[i].stageValue == 'Completed' ){
                      this.QuoteApprovedprogress = true;
                  }else if( result[i].stageValue == 'Current' ){
                      this.QuoteApprovedCurrent = true;
                  }else if( result[i].stageValue == 'NotStarted' ){
                      this.QuoteApprovedNotStarted = true;
                  }
              }else if( result[i].stageName == 'Art Started' ){
                  if( result[i].stageValue == 'Completed' ){
                      this.ArtStartedprogress = true;
                  }else if( result[i].stageValue == 'Current' ){
                      this.ArtStartedCurrent = true;
                  }else if( result[i].stageValue == 'NotStarted' ){
                      this.ArtStartedNotStarted = true;
                  }
              }else if( result[i].stageName == 'Art Ready' ){
                  if( result[i].stageValue == 'Completed' ){
                      this.ArtReadyprogress = true;
                  }else if( result[i].stageValue == 'Current' ){
                      this.ArtReadyCurrent = true;
                  }else if( result[i].stageValue == 'NotStarted' ){
                      this.ArtReadyNotStarted = true;
                  }
              }else if( result[i].stageName == 'Art Approved' ){
                  if( result[i].stageValue == 'Completed' ){
                      this.ArtApprovedprogress = true;
                  }else if( result[i].stageValue == 'Current' ){
                      this.ArtApprovedCurrent = true;
                  }else if( result[i].stageValue == 'NotStarted' ){
                      this.ArtApprovedNotStarted = true;
                  }
              }else if( result[i].stageName == 'Sizes Submitted' ){
                  if( result[i].stageValue == 'Completed' ){
                      this.SizeSubmittedprogress = true;
                  }else if( result[i].stageValue == 'Current' ){
                      this.SizeSubmittedCurrent = true;
                  }else if( result[i].stageValue == 'NotStarted' ){
                      this.SizeSubmittedNotStarted = true;
                  }
              }else if( result[i].stageName == 'Scheduled for Production' ){
                  if( result[i].stageValue == 'Completed' ){
                      this.ScheduledforProductionprogress = true;
                  }else if( result[i].stageValue == 'Current' ){
                      this.ScheduledforProductionCurrent = true;
                  }else if( result[i].stageValue == 'NotStarted' ){
                      this.ScheduledforProductionNotStarted = true;
                  }
              }
          }
        console.log('result',result);
       
       
    }).catch( (error) => {
           console.log('error'+error);
    })

    }
}