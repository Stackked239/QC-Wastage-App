import { LightningElement,track,wire} from 'lwc';
import createComments from '@salesforce/apex/SC_ArtProofingDetailApex.createorUpdateComments';
import getComments from '@salesforce/apex/SC_ArtProofingDetailApex.getComments';
import updateCoordinates from '@salesforce/apex/SC_ArtProofingDetailApex.updateCoordinates';
import fetchFilesRelatedToOrder from '@salesforce/apex/SC_ArtProofingDetailApex.fetchFilesRelatedToOrder';
import getLoggedInUserDetails from '@salesforce/apex/SC_ArtProofingDetailApex.getLoggedInUserDetails';
import { CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import saveProofInRevision from '@salesforce/apex/SC_ArtProofingDetailApex.saveProofInRevision';
import updateStage from '@salesforce/apex/SC_ArtProofingDetailApex.updateStage';
import updateInRevision from '@salesforce/apex/SC_ArtProofingDetailApex.updateInRevision';
import updateContentVersion from '@salesforce/apex/SC_ArtProofingDetailApex.updateContentVersion';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ContentVersion_Object from '@salesforce/schema/ContentVersion';

import Revision from '@salesforce/schema/ContentVersion.Revision_Choices__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadNewContentVersion from '@salesforce/apex/SC_ArtProofingDetailApex.uploadNewVersions'

//import communityPath from '@salesforce/community/basePath';




export default class SC_ArtProofingDetail extends LightningElement {
    @track commentCount = [];   
    @track commentDescription;
    @track commentsArr = [];
    newcommentsArr = [];
    currentPageReference = null; 
    urlStateParameters = null;
    @track ordId ;
    @track versionId ;
    @track fileUrl;
    @track AllfileVersions = [];
    @track fileVersionsToBeDisplay = [];
    contentDocList = [];
    @track value;
    @track orderName;
    //@track isRevise;
    @track revisionChoices;
    @track selectedRevisions = [];
    @track comment;
    @track sourceTab;
    @track isSourceTabArtApproval;
    @track isSourceTabRevision =false;
    @track currentUserName;
    @track isArtApprovalRevise = false;
    @track disabledReviseBtn = false;
    @track commentSaved = true;
    @track inRevisionComment='';
    @track lastCommentDateTime='';
    @track inRevisionCmntLabel = 'Add Comment';
    @track commentsWithCoord = [];
    @track currentUserInitials ='';
    @track currentUserTimeZone ='';
    @track orderCreatedDate;
    @track detailDisplayed = false;
    @track versionOnDisplay;
    @track showPopup = false;
    @track isSourceTabPreviousOrder;
    @track showVersionPicker = false;
    //@track showAllFileVersion = false;
    @track mustHaveDate;
    @track remainingDays;
    @track isLatest;
    @track hasRevisionOrComments;
    @track disableApproveBtn;
    @track isInternalUser=false; 
    @track showFileUploadModal = false;
    @track showcounter = false;
    timer;
    setTimeInterval;
    disableComment = false;
    @track tempComment = [];

    @track flowInputVariables = [];

    //@track fileNames = '';
    //@track filesUploaded = [];

    commentDisabled = true;
    
    get acceptedFormats() {
        return ['.png','.jpg','.jpeg'];
    }

    connectedCallback(){
     //   this.getUserDetails();    
    } 

    getUserDetails(){
        getLoggedInUserDetails().then((data) => {
            if(data){
                this.isInternalUser = data.UserType == 'Standard' ? true : false;
                console.log('this.isInternalUser'+this.isInternalUser);
                this.detailDisplayed = true;
                console.log(data)
                this.currentUserName = data.Name;  
                this.currentUserInitials = this.getInitials(data.Name);    
                this.currentUserTimeZone = data.TimeZoneSidKey; 

               //Called to fetch files added by WNC 09/03/2023
               this.fetchFiles();


                /** set the date according to the current user timezone **/
              /*  if(this.orderCreatedDate != undefined && this.orderCreatedDate != null){
                    var ddate = new Date(this.orderCreatedDate);
                    ddate = ddate.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                    ddate = ddate.includes(',') ? ddate.split(',')[0] : ddate;
                   // this.orderCreatedDate = ddate;
                } */           
               /* if(this.mustHaveDate != undefined && this.mustHaveDate != null){
                    var ddate = new Date(this.mustHaveDate);
                    ddate = ddate.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                    ddate = ddate.includes(',') ? ddate.split(',')[0] : ddate;
                   // this.mustHaveDate = ddate;
                    var todayDate = new Date().toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                    this.remainingDays = new Date(ddate).getDate() - new Date(todayDate).getDate();
                } */
            }
        }).catch((error) => {
            console.log('Error While Fetching Contact Infor....');
            // This way you are not to going to see [object Object]
            console.log('Error is', this.error);
        });            
    }

    getInitials(userName){
        console.log('getInitials   '+userName);
        var names = userName.split(' '),
        initials = names[0].substring(0, 1).toUpperCase();
        if (names.length > 1) {
            initials += names[names.length - 1].substring(0, 1).toUpperCase();
        }
        return initials;
    }

    @wire(getObjectInfo, { objectApiName: ContentVersion_Object })

    contentVersionMetadata;
    @wire(getPicklistValues, {
     recordTypeId: '$contentVersionMetadata.data.defaultRecordTypeId', 
     fieldApiName: Revision })
     setPicklistOptions({error, data}) {
        if (data) {
            console.log(data);
            var inp = [];
            for(var i=0;i<data.values.length;i++){
              var obj = {label:data.values[i].label,value:data.values[i].value};
              obj['style'] = 'background-color:white;padding-left:9px';
              inp.push(obj);
            }
            this.revisionChoices = inp;
        } else if (error) {
            console.log(error);
        }
    }


    @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }
    setParametersBasedOnUrl() {
       this.ordId =  this.urlStateParameters.c__Id !=undefined ? this.urlStateParameters.c__Id : this.urlStateParameters.Id ;


       console.log(' this.ordId'+ this.ordId)
       if(this.ordId != '' && this.ordId != null){
          this.getUserDetails();   
         // this.fetchFiles(); Commented by WNC 09/03/2023
          this.isPendingArtApproval = false;   
       }
         //this.sourceTab = this.urlStateParameters.c__source !=undefined ? this.urlStateParameters.c__source : this.urlStateParameters.source;
        //console.log(' this.sourceTab '+ this.sourceTab)

        /*************************** Commented By Navdeep **********************************/
       /* if(this.sourceTab == 'pending_approval' && this.detailDisplayed != true){
            this.isSourceTabArtApproval = true;
        }else if(this.sourceTab == 'pending_revision' && this.detailDisplayed != true){
            this.isSourceTabRevision = true;
        }else if(this.sourceTab == 'previous_orders' && this.detailDisplayed != true){
            this.isSourceTabPreviousOrder = true;
        }
        if(this.isSourceTabPreviousOrder == true || this.isSourceTabRevision == true || this.isSourceTabArtApproval == true)
            this.showVersionPicker = true;
        */
            this.isSourceTabArtApproval = false;



        /*if(this.isSourceTabRevision == true || this.isSourceTabArtApproval == true)
            this.showAllFileVersion = true; */
        console.log('showVersionPicker   '+this.showVersionPicker);
       console.log('source   '+this.urlStateParameters.source);
    }
    fetchFiles(){
        console.log('Is this internaluser'+this.isInternalUser);
        fetchFilesRelatedToOrder({orderId : this.ordId}).then((data) => {
            console.log('********************* FETCH FILES RELATED TO ORDER *****************************')
            if(data){       
                
                
                /*************** New Line added for disable comment **************/
                if(data.portalOrder.hasOwnProperty('In_Revision__c') && data.portalOrder.In_Revision__c && this.isInternalUser==false ){
                    this.disableComment = true;
                }
                console.log('this.disableComment'+this.disableComment);

                /********************* New Lines Added by Navdeep **********************/
                console.log('data.portalOrder'+JSON.stringify(data.portalOrder))
                console.log('this.detailDisplayed'+JSON.stringify(this.detailDisplayed))
                if(data.portalOrder.hasOwnProperty('Stage__c') && data.portalOrder.Stage__c=='Art Ready' &&  this.detailDisplayed == true){
                    this.isSourceTabArtApproval = true;
                    this.sourceTab = 'pending_approval';
                }
                else if(data.portalOrder.hasOwnProperty('Stage__c') && (data.portalOrder.Stage__c=='Art Approved' || data.portalOrder.Stage__c=='Sizes Submitted'
                  || data.portalOrder.Stage__c=='Scheduled for Production' ) &&  this.detailDisplayed == true){
                    this.isSourceTabPreviousOrder = true;
                    this.sourceTab = 'previous_orders'
                }
                else if( (data.portalOrder.hasOwnProperty('Stage__c') && data.portalOrder.Stage__c=='Art Started' && this.detailDisplayed == true) &&
                   ((data.portalOrder.hasOwnProperty('In_Revision__c') && data.portalOrder.In_Revision__c) 
                   || 
                    (data.portalOrder.hasOwnProperty('Submit_Revision_Time__c')))
                    ){
                    this.isSourceTabRevision = true;
                    this.sourceTab = 'pending_revision';
                }

                
                 console.log('this.sourceTab'+this.sourceTab)

                
                if(this.isSourceTabPreviousOrder == true || this.isSourceTabRevision == true || this.isSourceTabArtApproval == true)
                this.showVersionPicker = true;
                
                for(var j=0;j<data.contentDocumentsList.length;j++){
                    /** set first value as the default value of combobox **/
                    if(j==0)
                        this.value = data.contentDocumentsList[j].Id;
                    var obj ={};
                    obj['label'] = data.contentDocumentsList[j].Title;
                    obj['value'] = data.contentDocumentsList[j].Id;
                    this.contentDocList.push(obj);
                }
                this.contentDocList = JSON.parse(JSON.stringify(this.contentDocList));
                for(var i=0;i<data.contentVersionsList.length;i++){
                    if(i==0){   
                        this.versionId = data.contentVersionsList[i].Id;
                        this.fileId = data.contentVersionsList[i].ContentDocumentId; 
                        if(this.sourceTab  == 'pending_revision' || this.sourceTab  == 'previous_orders'){
                            if(data.contentVersionsList[i].Revision_Choices__c != undefined &&
                                data.contentVersionsList[i].Revision_Choices__c.includes(';')){
                                this.hasRevisionOrComments = true;
                                var sRevision=[];
                                data.contentVersionsList[i].Revision_Choices__c.split(';').forEach(function(item) {
                                sRevision.push({
                                    "label": item,
                                    "value" : item
                                    });
                                });
                                this.selectedRevisions = sRevision;
                            } else if(data.contentVersionsList[i].Revision_Choices__c != undefined){      
                            var sRevision ={};
                            sRevision['label'] = data.contentVersionsList[i].Revision_Choices__c;
                            sRevision['value'] = data.contentVersionsList[i].Revision_Choices__c;
                            this.selectedRevisions.push(sRevision);
                            }else{
                                this.hasRevisionOrComments = this.hasRevisionOrComments == true ? true : false;
                            }
                        }    
                        
                        var pathName = window.location.pathname.split('/s');
                        if(this.isInternalUser){
                            this.fileUrl = '/sfc/servlet.shepherd/version/download/'+ data.contentVersionsList[i].Id;     
                        }      
                        else{     
                            this.fileUrl  = pathName[0]+'/sfc/servlet.shepherd/version/download/'+ this.versionId;
                        }
                    }
                    if(data.contentVersionsList[i].ContentDocumentId )
                        var obj = {};
                    obj['versionName'] = 'Version '+ data.contentVersionsList[i].VersionNumber; 
                    obj['pathOnClient'] = data.contentVersionsList[i].PathOnClient; 
                    obj['isLatest'] = data.contentVersionsList[i].IsLatest; 
                    obj['versionId'] = data.contentVersionsList[i].Id;
                    obj['fileId'] = data.contentVersionsList[i].ContentDocumentId; 
                    obj['lastViewDate'] = data.contentVersionsList[i].Last_View_Date__c; 
                 
                    /***** New Line Added on 29/04/2022 *********/
                    obj['checkedvalue'] = false;  
                   
                    obj['style'] = i==0 ? 'max-height:100px;min-height: 100px;cursor:pointer;border-color: gray; border-width:thin;' : 'max-height:100px;min-height: 100px;cursor:pointer;';                   
                    obj['revisionChoices'] = data.contentVersionsList[i].Revision_Choices__c; 
                    console.log('this.isInternalUser deatil'+this.isInternalUser);
                    var pathName = window.location.pathname.split('/s');
                    if(this.isInternalUser){
                        console.log('isInternalUser')
                        obj['fileUrl'] =  '/sfc/servlet.shepherd/version/download/'+ data.contentVersionsList[i].Id;     
                    }
                    else{
                    obj['fileUrl'] = pathName[0]+'/sfc/servlet.shepherd/version/download/'+ data.contentVersionsList[i].Id;
                    }
                    this.AllfileVersions.push(obj);
                    if(data.contentVersionsList[i].ContentDocumentId ==  this.fileId){
                        this.versionOnDisplay = data.contentVersionsList[0].PathOnClient; 
                        this.isLatest = data.contentVersionsList[0].IsLatest;
                        this.disableApproveBtn = data.contentVersionsList[0].IsLatest == true ? false : true;
                        this.disabledReviseBtn = data.contentVersionsList[0].IsLatest == true ? false : true;
                        this.fileVersionsToBeDisplay.push(obj);
                        //this.handlePositioningOnInit();
                    }
                }

                updateContentVersion({contentVersionList : JSON.parse(JSON.stringify(this.fileVersionsToBeDisplay)), orderId:this.ordId }).then((data) => {

                })
                .catch((error)=>{
                    console.log('@@error');
                })
                
                this.orderName = data.portalOrder.Name;

    

                var ddate = new Date(data.portalOrder.CreatedDate);
                var mustHaveDate = new Date(data.portalOrder.Must_Have_Date__c);
                var approvedOn = new Date(data.portalOrder.Approved_On__c);
                var appNeededBy = new Date(data.portalOrder.Needs_Approval_Date__c);
                var revNeededBy = new Date(data.portalOrder.Revision_Needed_By_Date__c);


                /******************* New code for Timeout *********************/
                if(this.isSourceTabRevision==true){
                var revisionsubmitedtime = new Date(data.portalOrder.Submit_Revision_Time__c).getTime();
                var secondBetweenTwoDate = Math.ceil((new Date().getTime() - revisionsubmitedtime) / 1000);
                     if(secondBetweenTwoDate < 300){
                         secondBetweenTwoDate = 300 - secondBetweenTwoDate;

                        this.handleRevisionTimeout(secondBetweenTwoDate);
                     }
                }

                var todayDate = new Date();
                
               // if(this.currentUserTimeZone != undefined && this.currentUserTimeZone != '' ){
                   // ddate = ddate.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                  //  ddate = ddate.includes(',') ? ddate.split(',')[0] : ddate;
                        //ddate = new Intl.DateTimeFormat( 'en-US' ).format( ddate );
                    /** Pending Approval Tab **/
                    if(this.sourceTab == 'pending_approval' && appNeededBy != null){
                          //appNeededBy = new Intl.DateTimeFormat( 'en-US' ).format( appNeededBy );
                    //    appNeededBy = appNeededBy.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                      //  appNeededBy = appNeededBy.includes(',') ? appNeededBy.split(',')[0] : appNeededBy;
                        //  todayDate =     new Intl.DateTimeFormat( 'en-US' ).format( todayDate );
                          this.mustHaveDate = appNeededBy;
                          mustHaveDate = appNeededBy;
                    }
                    /** In Revision Tab **/
                    else if(this.sourceTab == 'pending_revision' && revNeededBy != null){
                   //     revNeededBy = new Intl.DateTimeFormat( 'en-US' ).format( revNeededBy );
                    //   revNeededBy = revNeededBy.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                   //    revNeededBy = revNeededBy.includes(',') ? revNeededBy.split(',')[0] : revNeededBy;
                     //   todayDate =  new Intl.DateTimeFormat( 'en-US' ).format( todayDate );
                        this.mustHaveDate = revNeededBy;
                        mustHaveDate = revNeededBy;
                    }
                    /** Previous Order Tab **/
                    else if(this.sourceTab == 'previous_orders' && approvedOn != null ){
                    //    approvedOn = new Intl.DateTimeFormat( 'en-US' ).format( approvedOn );
                      //  approvedOn = approvedOn.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});
                    //    approvedOn = approvedOn.includes(',') ? approvedOn.split(',')[0] : approvedOn;
                     //   todayDate =  new Intl.DateTimeFormat( 'en-US' ).format( todayDate );
                        this.mustHaveDate = approvedOn;
                        mustHaveDate = approvedOn;
                    }                   
              //  }                
                        
                this.orderCreatedDate = ddate;               
               
               /**************New Lines added by Navdeep *****/
              //  mustHaveDate = new Date(mustHaveDate);
               // todayDate = new Date(todayDate);
                if(JSON.stringify(mustHaveDate)!='null'){
                this.remainingDays = mustHaveDate.getDate() - todayDate.getDate();
                }
               
                this.flowInputVariables =  [{name: 'recordId',type: 'String',value: this.ordId},{name: 'selectedVersionId',type: 'String',value: this.versionId}];

                this.getInitComments();
            }
        }).catch((error) => {
          console.log('fetchFilesRelatedToOrder Error While Fetching Files....');
          this.error = error;
          // This way you are not to going to see [object Object]
           console.log('Error is', this.error);
       });
    }
   

    getInitComments(){
        this.commentsArr = [];
        getComments({OrderId : this.ordId, fileId : this.fileId,versionId : this.versionId}).then((result) => {
            console.log(result.length);
            if(result.length>0){ 
                this.hasRevisionOrComments = true; 
                var currentUserName = this.currentUserName;
                var currentUserTimeZone = this.currentUserTimeZone;
                this.commentCount.push(result.length);
            
                var temp= [];   
                for(var i=0; i< result.length; i++){
                    var item = result[i];  
                    /** convert the DateTime according to current user's timezone **/
                    var ddate = new Date(item.createdDateTime);
                    ddate = ddate.toLocaleString('en-US', {timeZone: currentUserTimeZone});
                    item.createdDateTime = ddate;
                    /** create a separate array for comments with coordinates **/
                    if(item.commentNumber != undefined && item.commentNumber != null)
                        temp.push(item);
                    /** add an attribute to give styling to the div **/
                    if(item.createdBy == currentUserName)
                        item['sameUser'] = true;
                    else
                        item['sameUser'] = false;
                    if(item.commentNumber != undefined && item.commentNumber != null)
                        item['hasCommentNumber'] = true;
                    else
                        item['hasCommentNumber'] = false;
                    /** store the user initials **/
                    item['userInitials']  = this.getInitials(item.createdBy);
                }
                this.commentsArr = result;  
                /** reverse the array to store the latest comment on the last index **/
                this.commentsWithCoord = temp; //.reverse();            
                /** get lastest comment's datetime **/           
                this.lastCommentDateTime = this.commentsArr[result.length-1].createdDateTime;
                /** loads the position of comment on init **/
                this.handlePositioningOnInit();
            }
            else if(result.length==0){
                this.hasRevisionOrComments = this.hasRevisionOrComments == true ? true : false;
                this.removeCommentsFromDOM();
                this.commentsArr = [];
                this.commentsWithCoord = [];  
                this.lastCommentDateTime = '';  
                /** loads the position of comment on init **/
                this.handlePositioningOnInit();
            }
        
        }).catch((error) => {
          console.log('In connected call back error....');
          this.error = error;
          // This way you are not to going to see [object Object]
           console.log('Error is', this.error);
        });
    }

    removeCommentsFromDOM(){
        const commentDiv =  this.template.querySelector('.annotations').children;
        if(commentDiv.length>0){
            for(var i=0;i<commentDiv.length;i++){
                commentDiv[i].remove();
            }
        }
    }

    allowDrop(event){
        event.preventDefault();
    }
    drop(event){
        console.log('drop');
        event.preventDefault();

        var rect = event.target.getBoundingClientRect();
        var x1 = event.clientX - rect.left-10;//+347;
        var y1 = (event.clientY - rect.top-10);//+294; 

        var divId = event.dataTransfer.getData("divId");
        const childDiv =  this.template.querySelector('.annotations').children;
        var recordId;
         for(var i=0 ;i<childDiv.length;i++){
             if(childDiv[i].getAttribute('id') == divId){
             recordId = childDiv[i].getAttribute('data-id');
             childDiv[i].style.left = x1+'px'; 
             childDiv[i].style.top = y1+'px';
             }
         }  
       
        this.updateCoord(recordId,x1,y1);    
        /*  console.log('divId'+divId)
        var draggedElement = this.template.querySelector('#' +divId);
        console.log('draggedElement'+draggedElement);
        console.log('event.target'+event.target);
        draggedElement.classList.add('completed'); 
        event.target.appendChild(draggedElement);*/
    }
    drag(event){
        event.dataTransfer.setData("divId", event.target.id);
    }
    createAnnotation(event){
        console.log('create annotaion');
        console.log('this.sourceTab'+this.sourceTab);
        console.log('this.disableComment'+this.disableComment);
        console.log('this.isLatest'+this.isLatest);
        console.log(' this.isArtApprovalRevise'+ this.isArtApprovalRevise);

        event.preventDefault();
        /** this function is for Revision tab **/
        if((this.sourceTab == 'pending_revision' || this.isArtApprovalRevise) && this.disableComment==false && this.isLatest == true && this.isInternalUser == false/*&& this.commentSaved == true*/){
            this.commentSaved = false;
            /** show the comment section **/
            //this.isRevise = true;             

              this.commentDisabled = false;

            var lastelement = 1 ;
            var lastElementFound = false;
            /**** Logic to increment comment and storing that in array ****/
            if(this.isSourceTabArtApproval == true && this.tempComment.length > 0){
                for(var i=this.tempComment.length-1; i>=0; i--){
                    if(this.tempComment[i].commentNumber != undefined){
                        lastelement  = this.tempComment[i].commentNumber;
                        lastelement = lastelement+1;
                        this.commentCount.push(lastelement);
                        lastElementFound = true;
                        break;
                    }
                }
            }
            if(this.commentsWithCoord.length==0 && lastElementFound == false){
                this.commentCount.push(1);
            }
            else if(lastElementFound == false){
                lastelement  = this.commentsWithCoord[this.commentsWithCoord.length-1].commentNumber;
                lastelement = lastelement+1;
                this.commentCount.push(lastelement);   
            }
            /** set the comment box label **/
            this.inRevisionCmntLabel = 'Add Comment for '+lastelement;

          
            /***** Logic to calculate mouse pointer position */
            var rect = event.target.getBoundingClientRect();
            var x1 = event.clientX - rect.left -10;//+347; //x position within the element. +325
            var y1 = event.clientY - rect.top-10;//+294;  //y position within the element. +27 +235             
        
            var arr = [];
            arr.push({'xPosition':x1,'yPosition':y1,
                                'commentCounter':lastelement,
                                'commDescription':'','recordId':''});

            x1 += 'px';
            y1 += 'px'; 
        
            var dropDiv = this.template.querySelector('.annotations');
    
            console.log(this.template.querySelector('.annotations').innerHTML)
            const commentDiv =  this.template.querySelector('.annotations').children;
            if(commentDiv != undefined && commentDiv.length>0){
                var commentArr   =  JSON.parse(JSON.stringify(commentDiv));
                for(var i=commentDiv.length-1;i>=0;i--){
                    if(commentDiv[i].getAttribute('id')=='comm'+lastelement){
                    commentDiv[commentDiv.length-1].remove();
                    }
                }
            }
        
            /*** Class attribute not working when adding class to it so hard coded styles for now */
            dropDiv.innerHTML  += '<div id="comm'+lastelement+'" data-status="NoSync" style="left:'+x1+';top:'+y1+';height:25px;'+
                               'display:inline-block;position:absolute;width:25px;pointer-events: none;'+    
                               'text-align: center;border: 3px solid black;'+
                               'border-radius:50%;background-color:white"><b>'+lastelement+'</b></div>';
            this.handleAddListeners();          
            console.log('JSON.stringify(arr)'+JSON.stringify(arr));

          

            this.newcommentsArr = JSON.parse(JSON.stringify(arr));
            console.log(dropDiv.innerHTML);         
       }
    }
    submitInRevision(){
        var arr = [];
        if(this.inRevisionComment != undefined && this.inRevisionComment != ''){
            var obj = this.newcommentsArr.length == 0 ? {} : this.newcommentsArr[0];
            obj['commDescription'] = this.inRevisionComment;
            obj['ordId'] = this.ordId;
            obj['versionId'] = this.versionId;
            obj['fileId'] = this.fileId;
            for(var i=0; i<this.newcommentsArr.length;i++){ 
                obj['commentNumber'] = obj.commentCounter;
                obj['xPosition'] = obj.xPosition;
                obj['yPosition'] = obj.yPosition;
            } 
            arr.push(obj);
        }
       
        createComments({commentList:arr})
        .then((result) => {
            console.log('newcommentsArr   '+this.newcommentsArr);
            /** update the variables **/
            this.newcommentsArr = [];
            this.inRevisionCmntLabel = 'Add Comment';
            this.commentSaved = true; 
            this.inRevisionComment = '';
            this.getInitComments();
        }).catch((error) => {
                console.log('Error is', this.error);
        });        
    }
    handleInRevisionComment(event){
        this.inRevisionComment = event.target.value;
    }
    handleSaveComment(){        
        if(this.commentDescription!=null || this.commentDescription!='' ){
           this.saveCommentsToDB();
        }
    }
    commentChange(event){
        this.commentDescription = event.target.value;
    }
    saveCommentsToDB(){
        var arr = [];
        for(var i=0; i<this.newcommentsArr.length;i++){
            var obj = this.newcommentsArr[i];
            obj['commDescription'] = this.commentDescription;
            obj['ordId'] = this.ordId;
            obj['versionId'] = this.versionId;
            obj['fileId'] = this.fileId;
            arr.push(obj);
        } 
        console.log(arr.length)
        createComments({commentList:arr})
        .then((result) => {

        }).catch((error) => {
                console.log('Error is', this.error);
        });  
    }

    updateCoord(Id,x1,y1){
        updateCoordinates({recordId: Id,x:x1,y:y1}).then((result) => {
            console.log(result);  
        }).catch((error) => {
            console.log('Update coordinate failed');
            this.error = error;
            // This way you are not to going to see [object Object]
            console.log('Error is', this.error);
        });
    }

    handlePositioningOnInit(){
        var dropDiv = this.template.querySelector('.annotations');  
        dropDiv.innerHTML = ''; 
        if(this.commentsWithCoord.length > 0){
            for(var i=0;i<this.commentsWithCoord.length;i++){
                var index = this.commentsWithCoord[i].commentNumber;
                var yposition = parseInt(this.commentsWithCoord[i].yPosition);
                console.log('yposition'+yposition);
                dropDiv.innerHTML += '<div data-id='+this.commentsWithCoord[i].recordId+' id="comm'+index+'" data-status="Sync" draggable="true" style="left:'+this.commentsWithCoord[i].xPosition+'px'+';top:'+yposition+'px'+';height:25px;'+
                                     'display:inline-block;position:absolute;width:25px;'+    
                                     'text-align: center;border: 3px solid black;'+
                                     'cursor: pointer;'+
                                     'border-radius:50%;background-color:white;"><b>'+index+'</b></div>';
               }
               this.handleAddListeners();
        }    
               
    }

    handleAddListeners(){
        if(this.isLatest ==true && this.isInternalUser == false){
        const childDiv =  this.template.querySelector('.annotations').children;
        for(var i=0 ;i<childDiv.length;i++){
            if(childDiv[i].getAttribute('data-status')=='Sync'){
                childDiv[i].addEventListener("click", this.handleDragOnClick, false);
                childDiv[i].addEventListener("dragstart", this.drag, false);
            }
        }  
        } 
    }

    handleDragOnClick(event){
        event.stopPropagation();
    }
    previewImgOnSel(event){
        this.hasRevisionOrComments = false;
        this.commentSaved = true;
        var versionid = event.currentTarget.dataset.id;
        console.log('fileVersionsToBeDisplay   '+JSON.stringify(this.fileVersionsToBeDisplay));
        this.selectedRevisions = [];
        console.log('previewImgOnSel change this.hasRevisionOrComments   '+this.hasRevisionOrComments)
        for(var i=0;i<this.fileVersionsToBeDisplay.length;i++){
            if(this.fileVersionsToBeDisplay[i].versionId==versionid){
                if(this.fileVersionsToBeDisplay[i].revisionChoices != undefined){
                    this.hasRevisionOrComments = true;
                    var sRevision=[];
                    this.fileVersionsToBeDisplay[i].revisionChoices.split(';').forEach(function(item) {
                    sRevision.push({
                        "label": item,
                        "value" : item
                    });
                });
                this.selectedRevisions = sRevision;
                }else{
                    this.hasRevisionOrComments = this.hasRevisionOrComments == true ? true : false; 
                }
                this.fileVersionsToBeDisplay[i].style = 'border-color: gray; border-width:thin;max-height:100px;min-height: 100px;cursor:pointer;';
                this.versionOnDisplay = this.fileVersionsToBeDisplay[i].pathOnClient;
                this.isLatest = this.fileVersionsToBeDisplay[i].isLatest;
                this.disableApproveBtn = this.fileVersionsToBeDisplay[i].isLatest == true ? false : true;
                this.disabledReviseBtn = this.fileVersionsToBeDisplay[i].isLatest == true ? false : true;
                this.versionId = versionid;
                this.fileId = this.fileVersionsToBeDisplay[i].fileId; 
                var pathName = window.location.pathname.split('/s');
                if(this.isInternalUser){
                this.fileUrl  = '/sfc/servlet.shepherd/version/download/'+ this.versionId;
                }
                else{
                 this.fileUrl  = pathName[0]+'/sfc/servlet.shepherd/version/download/'+ this.versionId;  
                }   
            }else{
                this.fileVersionsToBeDisplay[i].style = 'max-height:100px;min-height: 100px;cursor:pointer;';
            }
        }
        updateContentVersion({contentVersionList : JSON.parse(JSON.stringify(this.fileVersionsToBeDisplay)), orderId:this.ordId }).then((data) => {

        })
        .catch((error)=>{
            console.log('@@error');
        })
        console.log('fileVersionsToBeDisplay   '+JSON.stringify(this.fileVersionsToBeDisplay));
        this.getInitComments();
    } 
    handleChange (event){
        this.hasRevisionOrComments = false;
        this.commentSaved = true;
        var latestContentDoc = false;
        this.value = event.detail.value;
        this.fileVersionsToBeDisplay = [];
        this.selectedRevisions =[];
        for(var i=0;i<this.AllfileVersions.length;i++){
            if(this.AllfileVersions[i].fileId == this.value && latestContentDoc==false){
                if(this.AllfileVersions[i].revisionChoices != undefined){
                    this.hasRevisionOrComments = true;
                    var sRevision=[];
                    this.AllfileVersions[i].revisionChoices.split(';').forEach(function(item) {
                    sRevision.push({
                        "label": item,
                        "value" : item
                    });
                });
                this.selectedRevisions = sRevision;
                }else{
                    this.hasRevisionOrComments = this.hasRevisionOrComments == true ? true : false;
                }
                this.versionOnDisplay = this.AllfileVersions[i].pathOnClient;
                this.AllfileVersions[i].style = 'border-color: gray; border-width:thin;max-height:100px;min-height: 100px;cursor:pointer;';
                this.isLatest = this.AllfileVersions[i].isLatest;
                this.disableApproveBtn = this.AllfileVersions[i].isLatest == true ? false : true;
                this.disabledReviseBtn = this.AllfileVersions[i].isLatest == true ? false : true;
                this.versionId = this.AllfileVersions[i].versionId;
                this.fileId = this.value; 
                var pathName = window.location.pathname.split('/s');
                if(this.isInternalUser){
                    this.fileUrl  = '/sfc/servlet.shepherd/version/download/'+ this.versionId;
                }
                else{
                this.fileUrl  = pathName[0]+'/sfc/servlet.shepherd/version/download/'+ this.versionId;
                }
                latestContentDoc = true ;
            }
            if(this.AllfileVersions[i].fileId == this.value){   
                if(i!=0){
                    this.AllfileVersions[i].style = 'max-height:100px;min-height: 100px;cursor:pointer;';  
                }             
                this.fileVersionsToBeDisplay.push(this.AllfileVersions[i]);
            }
        }

        console.log('this.versionId on Change'+this.versionId);
        this.flowInputVariables = undefined;


        var inputObj = [];
        inputObj.push({name: 'recordId',type: 'String',value: this.ordId});
        inputObj.push({name: 'selectedVersionId',type: 'String',value: this.versionId});


        setTimeout(()=>{
            this.flowInputVariables = inputObj;
        },3000)

        updateContentVersion({contentVersionList : JSON.parse(JSON.stringify(this.fileVersionsToBeDisplay)), orderId:this.ordId }).then((data) => {

        })
        .catch((error)=>{
            console.log('@@error');
        })
        
        this.getInitComments();
    }
    handleArtApprovalRevise(){    
        console.log(' this.isArtApprovalRevise Before Update '+ this.isArtApprovalRevise );    
            if(this.isArtApprovalRevise){
                this.isArtApprovalRevise  = false;   
            } 
            else{
                this.isArtApprovalRevise  = true;     
            }

            this.disabledReviseBtn = true;
            //this.isArtApprovalRevise = this.isArtApprovalRevise == true ? false : true;
            console.log(' this.isArtApprovalRevise After Update '+ this.isArtApprovalRevise );

    }
    handleSelection(event){
        event.preventDefault();
       var dataId = event.currentTarget.dataset.id;
       var selectedRevison;
       for(var i=0;i<this.revisionChoices.length;i++){
           if(this.revisionChoices[i].value==dataId){
                if( this.revisionChoices[i].style.includes('background-color:white')){   
                   this.revisionChoices[i].style = 'background-color:#DCDCDC;padding-left:9px';
                }
                else{
                    this.revisionChoices[i].style='background-color:white;padding-left:9px'; 
                }
                selectedRevison = this.revisionChoices[i];
           }
       }
       if(this.selectedRevisions!=null && this.selectedRevisions.length>0){
          var found=false;
          for(var i=0;i<this.selectedRevisions.length;i++){
             if(this.selectedRevisions[i].value==dataId && selectedRevison.style.includes('background-color:white')){
                 found=true;
                 this.selectedRevisions.splice(i,1); 
              }
              else if(this.selectedRevisions[i].value==dataId){
                found=true;
              }
          } 
          if(found==false){
            this.selectedRevisions.push(selectedRevison); 
          }    
       }
       else{
           var arr = []
           arr.push(selectedRevison);
           console.log('arr'+arr);
           this.selectedRevisions = arr;
        }
    }
    handleRichTextChange(event){
        console.log(event.target.value)
    }
     NewComment(){
        console.log('NewComment   ');
        this.commentDisabled = false;

        if(this.comment != null){
            var tempComment = this.tempComment;
            var obj = {};
            var ddate = new Date();
            ddate = ddate.toLocaleString('en-US', {timeZone: this.currentUserTimeZone});

            obj['commDescription'] = this.comment;            
           // obj['createdDateTime'] = ddate;
            obj['createdBy'] = this.currentUserName;
            obj['userInitials']  = this.getInitials(this.currentUserName);
            obj['ordId'] = this.ordId;
            obj['versionId'] = this.versionId;
            obj['fileId'] = this.fileId;

            /** if the comment has coordinates **/
            if(this.inRevisionCmntLabel != 'Add Comment'){
                for(var i=0; i<this.newcommentsArr.length;i++){ 
                    obj['hasCommentNumber'] = true;
                    obj['commentNumber'] = this.newcommentsArr[i].commentCounter;
                    obj['xPosition'] = this.newcommentsArr[i].xPosition;
                    obj['yPosition'] = this.newcommentsArr[i].yPosition;
                } 
            }           
            
            tempComment.push(obj);
            /** reset the variables **/
            this.comment = null;
            this.tempComment = tempComment;
            this.inRevisionCmntLabel = 'Add Comment';
        }
    }
    handleArtApprovalSubmitRevision(){
        var selChoices = JSON.parse(JSON.stringify(this.selectedRevisions));
        var arr = [];
        var commentWrapper = [];

        for(var i=0;i<selChoices.length;i++){
            arr.push(selChoices[i].value);
        }

            var tempComment = this.tempComment;
            
            console.log('tempComment**************************'+JSON.stringify(tempComment));
            console.log('this.newcommentsArr'+JSON.stringify(this.newcommentsArr));
            console.log('this.comment'+this.comment);
        if(this.comment != null){
                var obj ={} ;
                obj['commDescription'] = this.comment;
                obj['ordId'] = this.ordId;
                obj['versionId'] = this.versionId;
                obj['fileId'] = this.fileId;
                console.log('obj 833 '+JSON.stringify(obj));
                for(var i=0; i<this.newcommentsArr.length;i++){ 
                    obj['commentNumber'] = this.newcommentsArr[i].commentCounter;//obj.commentCounter;
                    obj['xPosition'] = this.newcommentsArr[i].xPosition; //obj.xPosition;
                    obj['yPosition'] = this.newcommentsArr[i].yPosition; //obj.yPosition;
                } 
                tempComment.push(obj);
                console.log('tempComment'+JSON.stringify(tempComment));
        }
        saveProofInRevision({contentVerId : this.versionId,fileId:this.fileId,SelectedChoices : arr,myOrderId: this.ordId}).then((data) => {
            /** switch the tab to In Revision's detail page */
            this.isSourceTabRevision = true; 
            this.isSourceTabArtApproval = false; 
            this.sourceTab = 'pending_revision';
            this.showcounter = true;
            this.showVersionPicker = true;
            //this.showAllFileVersion = true;
   
            this.handleRevisionTimeout(300);

            this.getInitComments();
            const event = new ShowToastEvent({
                title: 'Saved Successful',
                message: 'Saved Successful',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);

        }).catch((error) => {
            console.log('Error While Saving Revision');
            this.error = error;
            // This way you are not to going to see [object Object]
             console.log('Error is', this.error);
         });

        createComments({commentList:tempComment})
        .then((result) => {
            console.log('createComments success!!!!   '+this.newcommentsArr);
            /** update the variables **/
            this.newcommentsArr = []; 
            this.inRevisionCmntLabel = 'Add Comment';
            this.commentSaved = true; 
            this.inRevisionComment = '';
            this.getInitComments();
        }).catch((error) => {
            console.log('createComments Error is', this.error);
        });  
    }

    handleRevisionTimeout(timeoutParam){
        this.showcounter = true;        
        var sec = timeoutParam;

        this.setTimeInterval =setInterval(() => {
            sec--;
            let minutes = Math.floor(sec / 60);
            let extraSeconds = sec % 60;
            minutes = minutes < 10 ? "0" + minutes : minutes;
            extraSeconds = extraSeconds < 10 ? "0" + extraSeconds : extraSeconds;

            this.timer =   minutes + "m "+ extraSeconds+ "s";  
            if (sec == 0) {
                clearInterval(this.setTimeInterval);
                this.disableComment = true;
                this.showcounter = false;
                
                updateInRevision({myOrderId: this.ordId}).then((data) => {
                    console.log('updateInRevision successful   ');
                }).catch((error) => {
                    console.log('Error While Updating In Revision');
                    this.error = error;
                    console.log('Error is', this.error);
                });
            }
         }, 1000);
    }

    handleArtApprovalCommentChange(event){
     this.comment = event.target.value;
    }
    handleApprove(event){
        this.showPopup = true;
        console.log('AllfileVersions    '+this.AllfileVersions.length);
    }
    closeModal(event){
        this.showPopup = false;
        this.showFileUploadModal = false;
    }
    approveModal(){
        

        updateStage({myOrderId: this.ordId, stage : 'Art Approved',fileId : this.fileId}).then((data) => {
            console.log('AllfileVersions    '+this.AllfileVersions.length);
            /** switch the tab to Previous Order's detail page
             this.isSourceTabRevision = false; 
             this.isSourceTabArtApproval = false; 
             this.isSourceTabPreviousOrder = true;
             this.sourceTab = 'previous_orders';
             this.getInitComments(); **/
             /** swtich to Previous Order tab **/      
             var pathName = window.location.pathname.split('/s');
      
         window.location.href = window.location.origin+pathName[0]+'/s/art-proofs?source=previous_orders';

             const event = new ShowToastEvent({
                 title: 'Saved Successful',
                 message: 'Saved Successful',
                 variant: 'success',
                 mode: 'dismissable'
             });
             this.dispatchEvent(event); 
 
         }).catch((error) => {
             console.log('Error While Saving Revision');
             this.error = error;
             // This way you are not to going to see [object Object]
              console.log('Error is', this.error);
          });


    }
    
    fileUploadModal(){
        this.showFileUploadModal = true;
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        var fileIDs = [];
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
            fileIDs.push(uploadedFiles[i].documentId);
        }
        uploadNewContentVersion({newfileIds : fileIDs , displayedFileId : this.fileId }).then((data)=>{


        }).catch((error) => {
             console.log('Error While Saving Revision');
             //this.error = error;
             // This way you are not to going to see [object Object]
              console.log('Error is', JSON.stringify(this.error));
          });
 
        this.showFileUploadModal = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
               // message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
               message: 'The order has moved to art ready',
                variant: 'success',
            }),
        );
        updateStage({myOrderId: this.ordId, stage : 'Art Ready',fileId : this.fileId}).then((data) => {
             window.location.href = window.location.origin+'/lightning/r/portal_my_order__c/'+this.ordId+'/view';
         }).catch((error) => {
             console.log('Error While Saving Revision');
             this.error = error;
             // This way you are not to going to see [object Object]
              console.log('Error is', this.error);
          });
    }
    
    

}