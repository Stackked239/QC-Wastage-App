import { LightningElement,track,wire} from 'lwc';
import fetchPendingArtApprove from '@salesforce/apex/SC_ArtProofingDetailApex.fetchPendingArtApproval';
import loggedInUserDetails from '@salesforce/apex/SC_ArtProofingDetailApex.getLoggedInUserDetails';
//import communityPath from '@salesforce/community/basePath';

export default class SC_ArtProofingListComponent extends LightningElement {

@track AllfileVersions = [];
@track contactName;
@track isInternalUser = false; 
currentUserTimeZone;
   connectedCallback(){

       
       this.getLoggedInUserInfor();
   }
   fetchPendingapproval(){
        fetchPendingArtApprove({type : 'In Revision'}).then((data) => {
            if(data){
               console.log(data)
               for( var j=0 ;j<data.length;j++){
              
                 if(data[j].hasOwnProperty('contentVersion')){  
                  var mustHaveDate = data[j].portalOrder.Revision_Needed_By_Date__c; 
                  var diffDays;
                  if(this.currentUserTimeZone != undefined && mustHaveDate != undefined){
                    mustHaveDate = new Date(mustHaveDate);
                    //mustHaveDate = mustHaveDate.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                    //mustHaveDate = mustHaveDate.includes(',') ? mustHaveDate.split(',')[0] : mustHaveDate;
                    var todayDate = new Date();//.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                    diffDays = new Date(mustHaveDate).getDate() - new Date(todayDate).getDate();
                  }

                  var pathName = window.location.pathname.split('/s');
                   var obj = {};
                   obj['versionId'] = data[j].contentVersion.Id;
                   obj['fileId'] = data[j].contentVersion.ContentDocumentId;
                  console.log('this.isInternalUser List'+this.isInternalUser);
                  if(this.isInternalUser){
                    obj['fileUrl'] = '/sfc/servlet.shepherd/version/download/'+ data[j].contentVersion.Id;;     
                   }
                  else{
                    obj['fileUrl'] = pathName[0]+'/sfc/servlet.shepherd/version/download/'+data[j].contentVersion.Id;;
                   }
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
       console.log('view proof in revision');
       console.log(event.target.dataset.id);
       if(this.isInternalUser==false){
        var pathName = window.location.pathname.split('/s');

      // window.location.href = window.location.origin+pathName[0]+'/s/art-proof-detail?Id='+event.target.dataset.id+'&source=pending_revision';
         window.location.href = window.location.origin+pathName[0]+'/s/art-proof-detail?Id='+event.target.dataset.id;
       }else{
        window.location.href = window.location.origin+'/lightning/n/Art_Proofing_Detail/?c__Id='+event.target.dataset.id+'&c__source=pending_revision';
       }
   }
   getLoggedInUserInfor(){
  
        loggedInUserDetails().then((data) => {
            if(data){
              this.isInternalUser = data.UserType == 'Standard' ? true : false;
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