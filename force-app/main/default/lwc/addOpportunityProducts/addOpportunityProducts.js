import { LightningElement, api, wire, track } from 'lwc';

// Importing schema methods
import OPPTY_NOTES_FIELD from '@salesforce/schema/Opportunity.PM_Notes__c';
import ID_FIELD from '@salesforce/schema/Account.Id';
import SAVEDOPPTY_FIELD from '@salesforce/schema/Opportunity.Saved_Opportunity_Products__c';
import TOTALGARMENT_FIELD from '@salesforce/schema/Opportunity.of_Items_Garments__c';
import BACK_COLOR_FIELD from '@salesforce/schema/Opportunity.Colors_on_Back__c';
import FRONT_COLOR_FIELD from '@salesforce/schema/Opportunity.Colors_on_Front__c';
import OTHER_COLOR_FIELD from '@salesforce/schema/Opportunity.Colors_on_Other__c';
import PROD_COUNT_FIELD from '@salesforce/schema/Opportunity.fw2__Product_Count__c';

// Importing standard lightning methods
import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';

// Importing custom apex methods from the custom controller
import getProds from '@salesforce/apex/AddOpptyProdsController.getBundleProds';
import getCustomSettings from '@salesforce/apex/AddOpptyProdsController.getCustomSettings';
import serviceProducts from '@salesforce/apex/AddOpptyProdsController.getSetUpProds';
import createOpportunityProducts from '@salesforce/apex/AddOpptyProdsController.createOpportunityProducts';
import getProductData from '@salesforce/apex/AddOpptyProdsController.getAllProducts';
import getPrice from '@salesforce/apex/AddOpptyProdsController.getSKUPrice';
import delOpptyProds from '@salesforce/apex/AddOpptyProdsController.deleteAllOpptyProds';

export default class AddOpportunityProducts extends LightningElement {
    //Start Properties for Add Product
  // Propoerties related to Data table
  @track value;
  @track error;
  @track data;
  @api sortedDirection = 'asc';
  @api sortedBy = 'Inventory_Sort_Order__c';
  @api filter = 'All';
  @api resultOption = 'All';
  ProductSKUOption = [];
  skuCodePicklistVal = [];
  hideAddProducts = true;
  selectedRecordsIds = [];
  selectedProductIds = [];
  markup2XL = parseFloat(2.50);
  markup3XL = parseFloat(3.50);
  // Properties related to pagination
  @track page = 1;
  @track pageSize = 25;
  @track pageActions = [];
  @track allProducts = [];
  @track firstPage = true;
  @track finalPage = false;
  @track totalPages = 0;
  @track totalRecordCount = 0;
  @track startingRecord = 1;
  @track endingRecord = 0;
  @track hasPageChanged = false;
  @track initialLoad = true;
  @track disabled = true;
  @track searchkey = '';

  // Properties for Popup
  @track isShowModal = false;

  result;
  firstLoad = true;
  selectedRows;
  //End Properties for Add Product

  skuCodePicklistValue;
  skuColorPicklistVal;

  skuCodeInput="";
  skucolorInput="";
  opptyNotes;

  showBlankCodeColorError=false;
  errorMessage="";

  garments='';
  backColor="";
  frontColor="";
  otherColor="";

  showProdEditor;
  showserviceProds;
  bundleProds="";
  prodsToInsert=[];

  opptyProdExists=true;
  subtotalPrice=0;
  serviceSubtotalPrice=0;
  qtytotal=0;
  grandTotal=0;

  isLoading = false;
  isLoadingMsg = "";

  @api recordId;

  serviceProdRecords=[];

  // Start Add Product JS
  actionExposureColumns = [
    { label: 'Name', fieldName: 'Name', sortable: true, wrapText: true},
    { label: 'Sort Order', fieldName: 'Inventory_Sort_Order__c',sortable: true},
    { label: 'SKU Code', fieldName: 'SKUID_SKU__c', sortable: true},
    { label: 'SKU Color', fieldName: 'SKUID_Color__c', sortable: true},
    { label: 'SKU Size', fieldName: 'SKUID_Size__c', sortable: true},
    { label: 'Description', fieldName: 'Description', sortable: true, wrapText: true,initialWidth: 480 }
  ];

  @wire(getProductData, {sortBy: '$sortedBy', sortDirection: '$sortedDirection', filter: '$filter',searchkey:'$searchkey',productList: '$prodsToInsert',selectedProductIds:'$selectedProductIds'})
  wiredProducts(value) {
      this.result = value;
      const { error, data } = value;
      if (data) {
          this.allProducts = data;
          this.totalRecordCount = data.length; 
          this.totalPages = Math.ceil(this.totalRecordCount / this.pageSize);
          this.pageActions = this.allProducts.slice(0,this.pageSize); 
          this.endingRecord = this.pageSize;
          this.error = undefined;
          if(this.page === 1) {
              if(this.totalPages === 1 || this.totalPages === 0){
                  this.firstPage = true;
                  this.finalPage = true;
              } else {
                  this.firstPage = true;
                  this.finalPage = false;
              }
          } else if(this.page === 0) {
              this.firstPage = true;
              this.finalPage = true;
          } else if(this.page === this.totalPages) {
              this.firstPage = false;
              this.finalPage = true;
          } else {
              this.firstPage = false;
              this.finalPage = false;
          }
      } else if (error) {
          this.error = error;
          console.log(error);
          this.data = undefined;
      }
      if(this.firstLoad){
          console.log('refreshing...');
          console.log('this.result', this.result);
          return refreshApex(this.result);
      }
  }

  // Wire method to get Opportunity field values
  @wire(getRecord, { recordId: '$recordId', fields: [OPPTY_NOTES_FIELD, SAVEDOPPTY_FIELD, BACK_COLOR_FIELD, FRONT_COLOR_FIELD, OTHER_COLOR_FIELD, TOTALGARMENT_FIELD, PROD_COUNT_FIELD] })
  currentOppty({error, data}){
      if(data){
          this.opptyNotes = data.fields.PM_Notes__c.value;
          this.backColor = data.fields.Colors_on_Back__c.value != null ? data.fields.Colors_on_Back__c.value : 0;
          this.frontColor = data.fields.Colors_on_Front__c.value != null ? data.fields.Colors_on_Front__c.value : 0;
          this.otherColor = data.fields.Colors_on_Other__c.value != null ? data.fields.Colors_on_Other__c.value : 0;
          this.garments = data.fields.of_Items_Garments__c.value != null ? data.fields.of_Items_Garments__c.value : 0;
          let savedOpptyProds = data.fields.Saved_Opportunity_Products__c.value;
          if(savedOpptyProds){
              this.prodsToInsert = JSON.parse(savedOpptyProds);
              console.log('@@@@this.prodsToInsert 0', this.prodsToInsert);
              this.reCalculateTotals();
              this.showProdEditor = true;
          }
          if(data.fields.fw2__Product_Count__c.value > 0)
            this.opptyProdExists = false;
      }
  }

  // Wire methods to get picklist values
 @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: 'Product2.SKUID_SKU__c' })
  skuCodePicklistVals(value){
      const { error, data } = value;
      if(data){
          this.skuCodePicklistValue = value;
          this.ProductSKUOption = data.values.map( objPL => {
              return {
                  label: `${objPL.label}`,
                  value: `${objPL.value}`
              };
          });
          const option = {
              label: 'All',
              value: 'All'
          };
          this.ProductSKUOption = [ ...this.ProductSKUOption,option];
      }  else if (error) {
          console.log(error);
      }
  }
  @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: 'Product2.SKUID_Color__c' })
  skuColorPicklistVal;
 
  //wire method to fetch service products details from custom setting
  @wire(getCustomSettings)
  myCustomSettings;

  // Wire method to fetch and display service setup products
  @wire(serviceProducts, {opptyId: '$recordId'})
  serviceProdDetails({error, data}){
    if(data){
      this.showserviceProds=true;
      let serviceProducts = data;
        for (var s=0 ; s<serviceProducts.length; s++){
        let tempObj=[];
        let serviceProdNames1 = this.myCustomSettings.data.Service_Products__c;
        let serviceProdNames2 = serviceProdNames1.replace(/['()]/g, "");
        let serviceProdNames3 = serviceProdNames2.split(',');
        if(serviceProducts[s].Name == serviceProdNames3[0]){
          tempObj.Name = 'CSA Art';
          tempObj.UnitPrice = 25.00;
          tempObj.Quantity = 1;
          tempObj.TotalPrice = 25.00;
        }
        else if(serviceProducts[s].Name == serviceProdNames3[1]){
          tempObj.Name = 'Screens';
          tempObj.UnitPrice = 15.00;
          tempObj.Quantity = 2;
          tempObj.TotalPrice = 30.00;
        }
        else if(serviceProducts[s].Name == serviceProdNames3[2]){
          tempObj.Name = 'Shipping';
          tempObj.UnitPrice = 25.00;
          tempObj.Quantity = 1;
          tempObj.TotalPrice = 25.00;
        }
        tempObj.OpportunityId = this.recordId;
        tempObj.Product2Id = serviceProducts[s].Id;
        
        this.serviceProdRecords[s] = tempObj;
        this.reCalculateScreenCount();
      }
      console.log('@@@this.serviceProdRecords - ', this.serviceProdRecords);
    }
    else if (error) {
      console.log(error);
    }
    else{
      this.showserviceProds=false;
    }
  }

  handleSKUCodeChange(event){
    this.skuCodeInput = event.detail.value;
  }

  handleSKUColorChange(event){
    this.skucolorInput = event.detail.value;
  }

  handleGarmentChange(event){
    this.garments = event.detail.value;
  }
   
  handleFrontColorChange(event){
    var changedColor = event.detail.value;
    if(changedColor == '' || changedColor == null)
      this.frontColor = 1;
    else
      this.frontColor = changedColor;
    
      this.reCalculateScreenCount();
  }

  handleBackColorChange(event){
    var changedColor = event.detail.value;
    if(changedColor == '' || changedColor == null)
      this.backColor = 0;
    else
      this.backColor = changedColor;
    
      this.reCalculateScreenCount();
  }
  
  handleOtherColorChange(event){
    var changedColor = event.detail.value;
    if(changedColor == '' || changedColor == null)
      this.otherColor = 0;
    else
      this.otherColor = changedColor;

    this.reCalculateScreenCount();
  }

  handleApplyChange(event){
    var nFrontColor = Number(this.frontColor);
    var nBackColor = Number(this.backColor);
    var nOtherColor = Number(this.otherColor);
    if((this.skuCodeInput == "" || this.skucolorInput == "" || this.garments == '') || 
      (nFrontColor < 1 || nFrontColor > 10) ||
      (nBackColor < 0 || nBackColor > 10) || (nOtherColor < 0 || nOtherColor > 10)
      ){
        this.showBlankCodeColorError=true;
        this.errorMessage="";
        if(this.skuCodeInput == "" || this.skucolorInput == "")
          this.errorMessage = "Please select a value for SKU Code and Color. ";
        if(this.garments == '')
          this.errorMessage = this.errorMessage + "Please select a value for Total Garments. ";
        if(nFrontColor < 1 || nFrontColor > 10)
          this.errorMessage = this.errorMessage + "Color on Front has to be between 1-10. ";
        if(nBackColor < 0 || nBackColor > 10)
          this.errorMessage = this.errorMessage + "Color on Back has to be between 0-10. ";
        if(nOtherColor < 0 || nOtherColor > 10)
          this.errorMessage = this.errorMessage + "Color on Other has to be between 0-10";
    }
    else{
      let prod2InsertLen = this.prodsToInsert.length;
      getProds({ skucode : this.skuCodeInput, skucolor : this.skucolorInput})
        .then(result => {
          this.bundleProds = JSON.parse(JSON.stringify(result));
          if(this.bundleProds.length == 0){
            this.showBlankCodeColorError=true;
            this.errorMessage = "No product exists for the selected combination of SKU & Color. Please choose a different combination.";
          }
          else{
            this.showBlankCodeColorError=false;
            this.showProdEditor = true;
            let opptyProdAttribs = {
              Quantity: 1,
              UnitPrice: 0,
              TotalPrice: 0,
              SKUID: ''
            };
            // let skuPrice=0;
            for(var key in this.bundleProds) {
              if (result.hasOwnProperty(key)) {
                this.prodsToInsert.map(e => e.Id).indexOf(this.bundleProds[key].Id);
                if(this.prodsToInsert.map(e => e.Id).indexOf(this.bundleProds[key].Id) === -1) {
                  this.prodsToInsert[prod2InsertLen] = Object.assign(this.bundleProds[key],opptyProdAttribs);
                  this.fetchSKUPrice(this.bundleProds[key].Id, prod2InsertLen, true ,this.bundleProds[key].SKUID_Size__c);
                  prod2InsertLen++;
                }
              }
            }
            console.log('@@@@prodsToInsert 1 - ',this.prodsToInsert);

            if(this.garments != '' && this.garments != null){
              let uniqueBundles = [... new Set(this.prodsToInsert.map((bundles) => bundles.SKUID_SKU__c + bundles.SKUID_Color__c ))];
              for(var i in this.prodsToInsert){
                if(uniqueBundles.length == 0){
                  this.prodsToInsert[i].Quantity = Number(Math.ceil((this.prodsToInsert[i].Size_Percentage__c * this.garments)/100).toFixed(0));
                }
                else{
                  this.prodsToInsert[i].Quantity = Number(Math.ceil((this.prodsToInsert[i].Size_Percentage__c * this.garments)/(100 * uniqueBundles.length)).toFixed(0));
                }
                
                if(this.prodsToInsert[i].Quantity < 1)
                  this.prodsToInsert[i].Quantity = 1;

                this.prodsToInsert[i].TotalPrice = (parseFloat(this.prodsToInsert[i].UnitPrice) * parseInt(this.prodsToInsert[i].Quantity)).toFixed(2);
              }
              this.reCalculateTotals();
              this.refreshUnitPriceApply();
            }
            else
              this.reCalculateTotals();

            this.prodsToInsert = [...this.prodsToInsert];
            console.log('@@@@prodsToInsert - 2',this.prodsToInsert);

            if(!(nBackColor == 0 && nFrontColor == 0 && nOtherColor == 0)){
              this.reCalculateScreenCount();
            }
          }
        })
      .catch(error => {
        this.error = error;
        console.log('@@@@error - ',this.error);
      })
    }
  }

  handleRemoveRow(event){
    this.prodsToInsert.splice( event.target.dataset.id, 1);
    this.prodsToInsert = [...this.prodsToInsert];
    this.reCalculateTotals();
  }

  handleRePriceRow(event){
    var nFrontColor = Number(this.frontColor);
    var nBackColor = Number(this.backColor);
    var nOtherColor = Number(this.otherColor);
    if((this.garments == '') || (nFrontColor < 1 || nFrontColor > 10) || (nBackColor < 0 || nBackColor > 10) || (nOtherColor < 0 || nOtherColor > 10)){
        this.showBlankCodeColorError=true;
        this.errorMessage="";
        if(this.garments == '')
          this.errorMessage = this.errorMessage + "Please select a value for Total Garments. ";
        if(nFrontColor < 1 || nFrontColor > 10)
          this.errorMessage = this.errorMessage + "Color on Front has to be between 1-10. ";
        if(nBackColor < 0 || nBackColor > 10)
          this.errorMessage = this.errorMessage + "Color on Back has to be between 0-10. ";
        if(nOtherColor < 0 || nOtherColor > 10)
          this.errorMessage = this.errorMessage + "Color on Other has to be between 0-10";
        }
    else{
      var prodToUpd = event.target.dataset.id;
      var skuDetails, skuPrice, skuId;
      getPrice({ prodId : this.prodsToInsert[event.target.dataset.id].Id, frontColor : this.frontColor, backColor : this.backColor, otherColor : this.otherColor, totalGarments : Number(this.garments)})
          .then(result => {
            skuDetails = result.split(',');
            skuId = skuDetails[0];
            skuPrice = skuDetails[1];
            this.prodsToInsert[prodToUpd].SKUID = skuId;
            this.prodsToInsert[prodToUpd].UnitPrice = skuPrice;
            if(this.prodsToInsert[prodToUpd].SKUID_Size__c == '2XL'){
              this.prodsToInsert[prodToUpd].UnitPrice = parseFloat(this.prodsToInsert[prodToUpd].UnitPrice) + this.markup2XL;
            }
            if(this.prodsToInsert[prodToUpd].SKUID_Size__c == '3XL'){
              this.prodsToInsert[prodToUpd].UnitPrice = parseFloat(this.prodsToInsert[prodToUpd].UnitPrice) + this.markup3XL;
            }
            this.prodsToInsert[prodToUpd].TotalPrice = (parseFloat(this.prodsToInsert[prodToUpd].UnitPrice) * parseInt(this.prodsToInsert[prodToUpd].Quantity)).toFixed(2);
            this.prodsToInsert = [...this.prodsToInsert];
            this.reCalculateTotals();
          })
          .catch(error => {
            this.error = error;
            console.log('@@@@error - ',this.error);
          })
        }
  }

  handleQtyChange(event){
    let prodKey = event.target.dataset.id;
    if(event.detail.value == null || event.detail.value == ""){
      this.prodsToInsert[prodKey].Quantity = 0;
      this.prodsToInsert[prodKey].TotalPrice = 0;
    }
    else{
      this.prodsToInsert[prodKey].Quantity = event.detail.value;
      if(this.prodsToInsert[prodKey].UnitPrice == null || this.prodsToInsert[prodKey].UnitPrice == "")
        this.prodsToInsert[prodKey].TotalPrice = 0;
      else
        this.prodsToInsert[prodKey].TotalPrice = (parseFloat(event.detail.value) * parseFloat(this.prodsToInsert[prodKey].UnitPrice)).toFixed(2);
    }
    this.prodsToInsert = [...this.prodsToInsert];

    this.reCalculateTotals();
  }

  handleUnitPriceChange(event){
    let productKey = event.target.dataset.id;
    if(event.detail.value == null || event.detail.value == ""){
      this.prodsToInsert[productKey].UnitPrice = 0;
      this.prodsToInsert[productKey].TotalPrice = 0;
    }
    else{
      this.prodsToInsert[productKey].UnitPrice = event.detail.value;
      if(this.prodsToInsert[productKey].Quantity == null || this.prodsToInsert[productKey].Quantity == "")
        this.prodsToInsert[productKey].TotalPrice = 0;
      else
        this.prodsToInsert[productKey].TotalPrice = (parseFloat(event.detail.value) * parseInt(this.prodsToInsert[productKey].Quantity)).toFixed(2);
    }
    this.prodsToInsert = [...this.prodsToInsert];

    this.reCalculateTotals();
  }

  handleServiceQtyChange(event){
    let serviceProdKey = event.target.dataset.id;
    this.serviceProdRecords[serviceProdKey].Quantity = event.detail.value;
    this.serviceProdRecords[serviceProdKey].TotalPrice = (parseFloat(event.detail.value) * parseFloat(this.serviceProdRecords[serviceProdKey].UnitPrice).toFixed(2)).toFixed(2);
    this.serviceProdRecords = [...this.serviceProdRecords];

    this.reCalculateServiceTotals();
  }

  handleServiceUnitPriceChange(event){
    let serviceProdKey = event.target.dataset.id;
    this.serviceProdRecords[serviceProdKey].UnitPrice = event.detail.value;
    this.serviceProdRecords[serviceProdKey].TotalPrice = (parseFloat(this.serviceProdRecords[serviceProdKey].UnitPrice) * parseInt(this.serviceProdRecords[serviceProdKey].Quantity)).toFixed(2);
    this.serviceProdRecords = [...this.serviceProdRecords];

    this.reCalculateServiceTotals();
  }
  handleServiceProdAdditionOnDelete(){
      serviceProducts({opptyId: this.recordId}).then(result => {
        this.showserviceProds =true;
        let serviceProducts  = result;
        for (var s=0 ; s<serviceProducts.length; s++){
          let tempObj=[];
          if(serviceProducts[s].Name == 'NRM-ART FEE'){
            tempObj.Name = 'CSA Art';
            tempObj.UnitPrice = 25.00;
            tempObj.Quantity = 1;
            tempObj.TotalPrice = 25.00;
          }
          else if(serviceProducts[s].Name == 'NRM-Screen Setup Fee'){
            tempObj.Name = 'Screens';
            tempObj.UnitPrice = 15.00;
            tempObj.Quantity = 2;
            tempObj.TotalPrice = 30.00;
          }
          else if(serviceProducts[s].Name == 'NRM - FedEx Ground'){
            tempObj.Name = 'Shipping';
            tempObj.UnitPrice = 25.00;
            tempObj.Quantity = 1;
            tempObj.TotalPrice = 25.00;
          }
          tempObj.OpportunityId = this.recordId;
          tempObj.Product2Id = serviceProducts[s].Id;
          this.serviceProdRecords[s] = tempObj;
          this.reCalculateScreenCount();
        }}).catch(error => {
          this.showserviceProds=false;
        });
      }
  async handleDeleteOpptyProds(){
    const result = await LightningConfirm.open({
      message: 'You are going to delete all existing opportunity products. Are you sure you want to continue?',
      variant: 'header',
      label: 'Delete Opportunity Products!',
      theme: 'error',
    });

    if(result){
      this.isLoading = true;
      this.isLoadingMsg = "Deleting Existing Opportunity Products.";

      delOpptyProds({ opptyId: this.recordId })
      .then(result => {
          this.error = undefined;
          if(result) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'All Existing Opportunity Products Deleted Successfully!',
                    variant: 'success',
                }),
            );
            this.isLoading = false;
              this.opptyProdExists = true;
              this.handleServiceProdAdditionOnDelete();
          }
      })
      .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error deleting opportunity product records',
                  message: error.body.message,
                  variant: 'error',
              }),
          );
          this.isLoading = false;
          console.log("error", JSON.stringify(this.error));
      });
    }
  }

  handleResetOpptyProds(){
    this.isLoading = true;
    this.isLoadingMsg = "Deleting Saved Opportunity Products from the Editor.";
    
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[SAVEDOPPTY_FIELD.fieldApiName] = null;

    const recordInput = { fields };
    updateRecord(recordInput)
        .then(() => {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Saved Opportunity Products Deleted.',
                  variant: 'success'
              })
          );
          this.isLoading = false;
          this.showProdEditor = false;
          this.prodsToInsert = [];
          this.prodsToInsert = [...this.prodsToInsert];
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting saved opportunity products',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.isLoading = false;
        });
  }

  handleSaveOpptyProds(showToastMsg){
    this.isLoading = true;
    this.isLoadingMsg = "Saving Opportunity Products in the Editor.";
    
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[TOTALGARMENT_FIELD.fieldApiName] = this.garments;
    fields[FRONT_COLOR_FIELD.fieldApiName] = Number(this.frontColor);
    fields[BACK_COLOR_FIELD.fieldApiName] = Number(this.backColor);
    fields[OTHER_COLOR_FIELD.fieldApiName] = Number(this.otherColor);
    if(showToastMsg == 'NO')
      fields[SAVEDOPPTY_FIELD.fieldApiName] = null;
    else
      fields[SAVEDOPPTY_FIELD.fieldApiName] = JSON.stringify(this.prodsToInsert);
    
    const recordInput = { fields };
    updateRecord(recordInput)
        .then(() => {
            if(showToastMsg != 'NO'){
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Success',
                      message: 'Opportunity Products Saved Successfully.',
                      variant: 'success'
                  })
              );
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error saving opportunity products',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.isLoading = false;
        });
  }

  //Method to insert opportunity products in the database
  handleCreateOpptyProds(){
    this.isLoading = true;
    this.isLoadingMsg = "Creating new Opportunity Products from the Editor.";
    let opptyProdsToInsert={};
    let l = this.prodsToInsert.length + 1;

    for(var p=0; p < this.prodsToInsert.length; p++){
      let tempOPObj={};
      tempOPObj.Name = this.prodsToInsert[p].Name;
      tempOPObj.UnitPrice = this.prodsToInsert[p].UnitPrice;
      tempOPObj.Quantity = this.prodsToInsert[p].Quantity;
      tempOPObj.SKUID_Color__c = this.prodsToInsert[p].SKUID_Color__c;
      tempOPObj.OpportunityId = this.recordId;
      tempOPObj.Product2Id = this.prodsToInsert[p].Id;
      opptyProdsToInsert[p] = tempOPObj;
    }

    for(var q=0; q < this.serviceProdRecords.length; q++){
      let tempOPObj1={};
      tempOPObj1.Name = this.serviceProdRecords[q].Name;
      tempOPObj1.UnitPrice = this.serviceProdRecords[q].UnitPrice;
      tempOPObj1.Quantity = this.serviceProdRecords[q].Quantity;
      tempOPObj1.SKUID_Color__c = this.serviceProdRecords[q].SKUID_Color__c;
      tempOPObj1.OpportunityId = this.recordId;
      tempOPObj1.Product2Id = this.serviceProdRecords[q].Product2Id;
      opptyProdsToInsert[l+q] = tempOPObj1;
    }
    console.log('@@@this.opptyProdsToInsert final', opptyProdsToInsert);
    
    createOpportunityProducts({ opptyProdLines : JSON.stringify(opptyProdsToInsert), opptyId: this.recordId })
    .then(result => {
        this.error = undefined;
        if(result !== undefined) {
          this.prodsToInsert = [];
          this.serviceProdRecords = [];  
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Opportunity Products Created Successfully!',
                    variant: 'success',
                }),
            );
        }
        this.isLoading = false;
        this.showProdEditor = false;
        this.showserviceProds = false;
        this.subtotalPrice = 0;
        this.serviceSubtotalPrice = 0;
        this.grandTotal = 0;
        console.log(JSON.stringify(result));
        this.handleSaveOpptyProds('NO');
        // this.handleResetOpptyProds();
    })
    .catch(error => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating opportunity product records',
                message: error.body.message,
                variant: 'error',
            }),
        );
        this.isLoading = false;
        console.log("error", JSON.stringify(this.error));
    });
  }

  // Start Add Product Helper JS
  handleFilterChange(evt){
    this.filter = evt.target.value;
    this.selectedProductIds = this.selectedRecordsIds;
    return refreshApex(this.result);
  }

  handleResultChange(evt){
      this.resultOption = evt.target.value;
      return refreshApex(this.result);
  }

  displayRecordPerPage(){          
      this.totalRecordCount = this.allProducts.length;
      var tempRoster = [];
      // Calculate the starting record number
      var startingIndex = (this.page * this.pageSize) - this.pageSize;
      this.totalPages = Math.ceil(this.allProducts.length / this.pageSize);
      if(this.page === 1) {
          if(this.totalPages === 1 || this.totalPages === 0){
              this.firstPage = true;
              this.finalPage = true;
          } else {
              this.firstPage = true;
              this.finalPage = false;
          }
      } else if(this.page === 0) {
          this.firstPage = true;
          this.finalPage = true;
      } else if(this.page === this.totalPages) {
          this.firstPage = false;
          this.finalPage = true;
      } else {
          this.firstPage = false;
          this.finalPage = false;
      }
      if(this.totalRecordCount > 0){
          var rows = 0;
          if(this.finalPage){
              var rowsLeft = this.allProducts.length - startingIndex;
              rows = rowsLeft + startingIndex;
          } else {
              var tempRows = ((this.pageSize < this.allProducts.length) ? this.pageSize : this.allProducts.length);
              rows= (this.page * tempRows);
          }
          for(var i = startingIndex; i < rows; i++) {
              tempRoster.push(this.allProducts[i]);
          }
      }
      // Assign the contents of the new page of results to the correct property to re-render the table
      this.pageActions = JSON.parse(JSON.stringify(tempRoster));
  } 

  sortColumns( event ) {
      this.sortedBy = event.detail.fieldName;
      this.sortedDirection = event.detail.sortDirection;
      return refreshApex(this.result);
  }

  //clicking on first button this method will be called
  firstHandler() {
      this.hasPageChanged = true;
      this.page = 1;
      this.displayRecordPerPage();
  }

  //clicking on last button this method will be called
  lastHandler() {
      this.hasPageChanged = true;
      var lastPage = Math.ceil(this.totalRecordCount / this.pageSize); 
      this.page = lastPage;
      this.displayRecordPerPage();
  }

  //clicking on previous button this method will be called
  previousHandler() {
      this.hasPageChanged = true;
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage();
  }

  //clicking on next button this method will be called
  nextHandler() {
      this.hasPageChanged = true;
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage();                        
  }
   async handleSearch( event ) {
      this.searchkey = event.target.value;
      this.selectedProductIds = this.selectedRecordsIds;
      return refreshApex(this.result);
  }

  handleRowSelection(event) {
    this.selectedRows = event.detail.selectedRows;
  }

checkboxSelect(event){
  var selectedRec = event.target.checked;
  let productId= event.target.dataset.id;
  var updatedAllRecords = [];
  var updatedPaginationList = [];
  var listOfAllProducts = this.allProducts;
  var PaginationList = this.pageActions;
  this.selectedRecordsIds = [];
  let checkboxValue= event.target.value;
  checkboxValue= selectedRec;

  for(var i=0;i<PaginationList.length;i++){
  let productRecord=  JSON.parse(JSON.stringify(PaginationList[i]));
   if(productRecord.product.Id==productId){
      productRecord.isChecked = selectedRec;
      checkboxValue= selectedRec;
   }
    updatedPaginationList.push(productRecord);
  }

  this.pageActions= updatedPaginationList;

  for (var i = 0; i < listOfAllProducts.length; i++) {
    let productRecord=  JSON.parse(JSON.stringify(listOfAllProducts[i]));
    if(productRecord.product.Id == productId){
       productRecord.isChecked= selectedRec;
    }
    if(productRecord.isChecked == true){
      this.selectedRecordsIds.push(productRecord.product.Id);
    }
    updatedAllRecords.push(productRecord);
  }
  this.allProducts= updatedAllRecords;
  if(this.selectedRecordsIds.length > 0){
    this.hideAddProducts = false;
  }
  if(this.selectedRecordsIds.length === 0){
    this.hideAddProducts = true;
  }
  console.log('@@ this.selectedRecordsIds',this.selectedRecordsIds);
}  
clearSelections= (event)=>{
    this.hideAddProducts = true;
    let updatedAllRecords=[];
    this.selectedRecordsIds = [];
    var listOfAllProducts = this.allProducts;

    for (var i = 0; i < listOfAllProducts.length; i++) {
      let productRecord=  JSON.parse(JSON.stringify(listOfAllProducts[i]));
        if (productRecord.isChecked == true) {
          productRecord.isChecked = false;
        }
        updatedAllRecords.push(productRecord);
    }
    this.allProducts= updatedAllRecords;
    this.template.querySelectorAll('lightning-input[data-name="selected"]').forEach(item=>{
      item.checked = false; 
      })
      this.resetfilter();
  }
  showModalBox() {
      this.hideAddProducts = true;
      this.resetfilter();
      this.isShowModal = true;
  }

  async handleNewProductSelection(){
    this.isShowModal = false;
    let selectedProducts = JSON.parse(JSON.stringify(this.allProducts));
    let selectedRecords = selectedProducts.filter(item=> item.isChecked==true);

    let newProd = selectedRecords.map(item => {
     return item.product;
    });
    if (newProd.length > 0) {
        for (var i=0; i<newProd.length; i++) {
          if(this.prodsToInsert.map(el => el.Id).indexOf(newProd[i].Id) === -1) {
              newProd[i].Quantity = 1;
              console.log('new prod',newProd);
              await getPrice({ prodId : newProd[i].Id, frontColor : this.frontColor, backColor : this.backColor, otherColor : this.otherColor, totalGarments : Number(this.garments)})
                  .then(result => {
                    newProd[i].UnitPrice = result.split(',')[1];
                    //newProd[i].TotalPrice = result.split(',')[1];
                    if(newProd[i].SKUID_Size__c == '2XL'){
                      newProd[i].UnitPrice = parseFloat(newProd[i].UnitPrice) + this.markup2XL;
                    }
                    if(newProd[i].SKUID_Size__c == '3XL'){
                      newProd[i].UnitPrice = parseFloat(newProd[i].UnitPrice) + this.markup3XL;
                    }
                    newProd[i].TotalPrice = newProd[i].UnitPrice;
                  })
                  .catch(error => {
                    this.error = error;
                    console.log('@@@@error - ',this.error);
                  });

              this.prodsToInsert.push(newProd[i]);
          }
          else{
            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Warning',
                  message: 'Atleast one of the selected Product already exists in the editor. Remaining products are added.',
                  variant: 'warning'
              })
            );
          }
          this.prodsToInsert = [...this.prodsToInsert];
          this.reCalculateTotals();
        }
      }
  
    console.log('@@@this.prodToInsert5 ',this.prodsToInsert);
  }

  hideModalBox() {  
      this.isShowModal = false;
      this.resetfilter();
  }

  resetfilter(){
      this.filter = 'All';
      this.searchkey ='';
      this.selectedProductIds = [];
      this.selectedRecordsIds = [];
      return refreshApex(this.result);
  }

  refreshTable(){
      return refreshApex(this.result);
  }
    // End Add Product Helper JS

  //Methods to re-calculate the totals
  reCalculateTotals(){
    let priceSubTotal=0;
    let qtyTotalCalc=0;
    
    for(var m in this.prodsToInsert){
      priceSubTotal = (parseFloat(priceSubTotal) + parseFloat(this.prodsToInsert[m].TotalPrice)).toFixed(2);
      qtyTotalCalc = qtyTotalCalc + Number(this.prodsToInsert[m].Quantity);
    }

    this.subtotalPrice = parseFloat(priceSubTotal).toFixed(2);
    this.qtytotal = qtyTotalCalc;
    this.grandTotal = (parseFloat(this.subtotalPrice) + parseFloat(this.serviceSubtotalPrice)).toFixed(2);
  }

  reCalculateServiceTotals(){
    let serviceSubTotal=0;
      for(var sp in this.serviceProdRecords){
        serviceSubTotal = (parseFloat(serviceSubTotal) + parseFloat(this.serviceProdRecords[sp].TotalPrice)).toFixed(2);
      }
      this.serviceSubtotalPrice = parseFloat(serviceSubTotal).toFixed(2);
      this.grandTotal = (parseFloat(this.subtotalPrice) + parseFloat(this.serviceSubtotalPrice)).toFixed(2);
  }

  reCalculateScreenCount(){
    var serSubTot=0;
    var screenCount = Number(this.backColor) + Number(this.frontColor) + Number(this.otherColor);
    for(var sp in this.serviceProdRecords){
      if(this.serviceProdRecords[sp].Name == 'Screens'){
        this.serviceProdRecords[sp].Quantity = screenCount;
        this.serviceProdRecords[sp].TotalPrice = Number(screenCount) * this.serviceProdRecords[sp].UnitPrice;
        serSubTot=serSubTot+this.serviceProdRecords[sp].TotalPrice;
        this.serviceProdRecords = [...this.serviceProdRecords];
      }
      else{
        serSubTot=serSubTot+this.serviceProdRecords[sp].TotalPrice;
      }
      this.serviceSubtotalPrice=serSubTot;
      this.grandTotal = (parseFloat(this.subtotalPrice) + parseFloat(this.serviceSubtotalPrice)).toFixed(2);
    }
  }

  fetchSKUPrice(productId, position, override ,size){
    var skuDetails, skuPrice, skuId;
    getPrice({ prodId : productId, frontColor : this.frontColor, backColor : this.backColor, otherColor : this.otherColor, totalGarments : Number(this.garments)})
      .then(result => {
        skuDetails = result.split(',');
        console.log('@@@@ skuDetails ',skuDetails);
        skuId = skuDetails[0];
        skuPrice = skuDetails[1];
        if(size == '2XL'){
          skuPrice = parseFloat(skuPrice) + this.markup2XL;
        }
        if(size == '3XL'){
          skuPrice = parseFloat(skuPrice) + this.markup3XL;
        }
        if(override || (!override && skuId != this.prodsToInsert[position].SKUID)){
          this.prodsToInsert[position].SKUID = skuId;
        this.prodsToInsert[position].UnitPrice = skuPrice;
        this.prodsToInsert[position].TotalPrice = (parseFloat(skuPrice) * parseInt(this.prodsToInsert[position].Quantity)).toFixed(2);

        this.prodsToInsert = [...this.prodsToInsert];
        this.reCalculateTotals();
        }
      })
      .catch(error => {
        this.error = error;
        console.log('@@@@error - ',this.error);
      });

      return skuPrice;
  }

  refreshUnitPrice(){
    for(var i in this.prodsToInsert){
      this.fetchSKUPrice(this.prodsToInsert[i].Id, i, true , this.prodsToInsert[i].SKUID_Size__c);
    }
  }

  refreshUnitPriceApply(){
    for(var i in this.prodsToInsert){
      this.fetchSKUPrice(this.prodsToInsert[i].Id, i, false , this.prodsToInsert[i].SKUID_Size__c);
    }
  }
  handleKeyDown(event) {
    if (event.key === 'Tab') {
      event.preventDefault();
      const inputs = this.template.querySelectorAll('lightning-input');
      for (let i = 0; i < inputs.length; i++) {
        if (inputs[i] === document.activeElement) {
          if (i === inputs.length - 1) {
            inputs[0].focus();
          } else {
            inputs[i + 1].focus();
          }
          inputs[i + 1].select();
          break;
        }
      }
    }
  }
}