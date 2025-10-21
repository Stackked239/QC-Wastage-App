import { LightningElement,track,wire} from 'lwc';
import fetchPendingArtApproval from '@salesforce/apex/SC_ArtProofingDetailApex.fetchPendingArtApproval';
import loggedInUserDetails from '@salesforce/apex/SC_ArtProofingDetailApex.getLoggedInUserDetails';
//import communityPath from '@salesforce/community/basePath';


export default class SC_ArtProofingListComponent extends LightningElement {

@track AllfileVersions = [];
@track contactName;
currentUserTimeZone;

  connectedCallback(){
      this.getLoggedInUserInfor();
  }
  fetchPendingapproval(){
    fetchPendingArtApproval({type : 'Art Approval'}).then((data) => {
      console.log('data  Art Approval '+data);
      if(data){
        console.log(data)
        for( var j=0 ;j<data.length;j++){              
          if(data[j].hasOwnProperty('contentVersion')){ 
            var mustHaveDate = data[j].portalOrder.Needs_Approval_Date__c;
            var diffDays;
            if(this.currentUserTimeZone != undefined && mustHaveDate != undefined){
              mustHaveDate = new Date(mustHaveDate);
              //mustHaveDate =   new Intl.DateTimeFormat(this.currentUserTimeZone).format( mustHaveDate );
            //  mustHaveDate = mustHaveDate.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
           //   mustHaveDate = mustHaveDate.includes(',') ? mustHaveDate.split(',')[0] : mustHaveDate;
              var todayDate = new Date().toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
              todayDate = todayDate.includes(',') ? todayDate.split(',')[0] : todayDate;
              console.log('mustHaveDate   '+typeof mustHaveDate);
              diffDays = new Date(mustHaveDate).getDate() - new Date(todayDate).getDate();
            }   
            var pathName = window.location.pathname.split('/s');
              var obj = {};
              obj['versionId'] = data[j].contentVersion.Id;
              obj['fileId'] = data[j].contentVersion.ContentDocumentId;
              obj['fileUrl'] = pathName[0]+'/sfc/servlet.shepherd/version/download/'+ data[j].contentVersion.Id;
              obj['OrderName'] =  data[j].portalOrder.Name;
              obj['MustHaveDate'] = mustHaveDate;
              obj['RemainingDays'] = diffDays;
              obj['OrderId'] = data[j].portalOrder.Id;
              console.log(obj)
              this.AllfileVersions.push(obj);
          }
        }
        console.log('AllFileVersion'+JSON.stringify(this.AllfileVersions));
      }
    }).catch((error) => {
      console.log(error)
      console.log('Error While Fetching Files....');
      // This way you are not to going to see [object Object]
      console.log('Error is', this.error);
    });
  }
  viewProof(event){
       console.log('view proof');
       console.log(event.target.dataset.id);
       var pathName = window.location.pathname.split('/s');

      // window.location.href = window.location.origin+pathName[0]+'/s/art-proof-detail?Id='+event.target.dataset.id+'&source=pending_approval';

      window.location.href = window.location.origin+pathName[0]+'/s/art-proof-detail?Id='+event.target.dataset.id;
  }
  getLoggedInUserInfor(){
        loggedInUserDetails().then((data) => {
            if(data){
              console.log(data)
              this.contactName = data.Name;  
              this.currentUserTimeZone = data.TimeZoneSidKey;
              this.fetchPendingapproval(); 
            }
          }).catch((error) => {
          console.log('Error While Fetching Contact Infor....');
          this.error = error;
          // This way you are not to going to see [object Object]
           console.log('Error is', this.error);
       });
                
  }
}