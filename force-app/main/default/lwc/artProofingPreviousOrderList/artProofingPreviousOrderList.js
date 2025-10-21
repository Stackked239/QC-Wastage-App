import { LightningElement,track,wire} from 'lwc';
import fetchPendingArtApproval from '@salesforce/apex/SC_ArtProofingDetailApex.fetchPendingArtApproval';
import loggedInUserDetails from '@salesforce/apex/SC_ArtProofingDetailApex.getLoggedInUserDetails';
//import communityPath from '@salesforce/community/basePath';

export default class ArtProofingPreviousOrderList extends LightningElement {

@track AllfileVersions = [];
@track contactName;
connectedCallback(){
    this.fetchPendingapproval();
    this.getLoggedInUserInfor();
}
fetchPendingapproval(){
  fetchPendingArtApproval({type : 'Pending Order'}).then((data) => {
        if(data){
            console.log('AllFileVersion   '+this.AllfileVersions.length);
           console.log(data)
           var pathName = window.location.pathname.split('/s');
           for( var j=0 ;j<data.length;j++){          
             if(data[j].hasOwnProperty('contentVersion')){  
               var obj = {};
               obj['versionId'] = data[j].contentVersion.Id;
               obj['fileId'] = data[j].contentVersion.ContentDocumentId;
               obj['fileUrl'] = pathName[0]+'/sfc/servlet.shepherd/version/download/'+ data[j].contentVersion.Id;
               obj['OrderName'] =  data[j].portalOrder.Name;
               obj['Stage'] =  data[j].portalOrder.Stage__c;
               obj['OrderId'] = data[j].portalOrder.Id;
               console.log(obj)
               this.AllfileVersions.push(obj);
             }
           }
           console.log('AllFileVersion  '+JSON.stringify(this.AllfileVersions));
           console.log('AllFileVersion  '+this.AllfileVersions.length);
        }
      }).catch((error) => {
          console.log(error)
      console.log('Error While Fetching Files....');
      // This way you are not to going to see [object Object]
       console.log('Error is', this.error);
   });
}

getLoggedInUserInfor(){
    loggedInUserDetails().then((data) => {
        if(data){
          console.log(data)
          this.contactName = data.Name;  
        }
      }).catch((error) => {
      console.log('Error While Fetching Contact Infor....');
      this.error = error;
      // This way you are not to going to see [object Object]
       console.log('Error is', this.error);
   });            
}
viewProof(event){
  console.log('view proof previous order');
  console.log(event.target.dataset.id);
  var pathName = window.location.pathname.split('/s');

  //window.location.href = window.location.origin+pathName[0]+'/s/art-proof-detail?Id='+event.target.dataset.id+'&source=previous_orders';
    window.location.href = window.location.origin+pathName[0]+'/s/art-proof-detail?Id='+event.target.dataset.id;

}

}