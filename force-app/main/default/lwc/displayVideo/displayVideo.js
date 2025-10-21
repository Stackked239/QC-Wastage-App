import { LightningElement } from 'lwc';
import getUserDetail from '@salesforce/apex/displayVideoController.getUserDetail';
import updateUser from '@salesforce/apex/displayVideoController.updateUser';

export default class DisplayVideo extends LightningElement {
   
  showModal = false;
  showMessageModal = false;
  message;

  renderedCallback() {
    const videoElement = this.template.querySelector('video');
    if (videoElement) {
      videoElement.addEventListener('ended', this.handleVideoEnded);
    }
  }
  

  connectedCallback(){
    this.getUserDetails();
    //console.log("Initiated Video Comp");
  }

  getUserDetails() {
    getUserDetail({})
        .then(result => {
              this.showModal = result.See_the_Video__c;
        })
        .catch(error => {
            console.error('Error fetching user details: ', error);
        });
  }

  handleVideoEnded(){
    updateUser()
        .then(()=> {
          this.showModal = false;
          this.showMessageModal = true;
          this.message= "Hey there, future you! If you're feeling nostalgic and want to re-watch this awesome video again, just flip the switch in your profile and let the good times roll!";
        })
        .catch(error => {
            console.log('Error Occured:- '+error.body.message);
        });
  }

  handleHideButtonClick() {
    const videoElement = this.template.querySelector('video');
    videoElement.pause();
  
     updateUser()
        .then(()=> {
          this.showModal = false;
          this.showMessageModal = true;
          this.message=  "If you change your mind and want to come back to this awesome video later, you can always turn it back on from your profile. Dont miss out on all the fun!";
        })
        .catch(error => {
            console.log('Error Occured:- '+error.body.message);
        });
  }

  handleOKButtonClick(){
    this.showMessageModal = false;
  }


  handlePlay() {
    const video = this.template.querySelector('video');
    //console.log(video);
    video.play();
    video.controls = true;
    this.template.querySelector('.play-button').style.display = 'none';
  }

  hideModalBox(){
    this.showModal= false;
  }
}