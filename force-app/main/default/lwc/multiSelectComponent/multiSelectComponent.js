import { LightningElement,api,track } from 'lwc';
import{loadStyle} from 'lightning/platformResourceLoader';
import pillClass from '@salesforce/resourceUrl/Lightning_Pill_Class';

export default class MultiSelectComponent extends LightningElement {

    @api listOptions;
    @api garmentType;
    @api selectedValues;
    @track selValues=[];
    @track listOfOptions=[];
    @track allValues=[];
    @track allLabels=[];
    @track value;

    connectedCallback(){

      Promise.all([loadStyle(this,pillClass)]);

        if(this.garmentType==='Adult Short Sleeve'){
          this.listOptions = [{ value: 'Heather_Burgundy', label: 'Heather Burgundy' },
                                { value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                { value: 'Heather_Grape', label: 'Heather Grape' },
                                { value: 'Heather_Graphite', label: 'Heather Graphite' },
                                { value: 'Heather_Honey', label: 'Heather Honey' },
                                { value: 'Heather_Kelly', label: 'Heather Kelly' },
                                { value: 'Heather_Melon', label: 'Heather Melon' },
                                {value: 'Heather_Mil_Green', label: 'Heather Mil Green'},
                                {value: 'Heather_Mint_Julep', label: 'Heather Mint Julep'},
                                {value: 'Heather_Purple', label: 'Heather Purple'},
                                {value: 'Heather_Red', label: 'Heather Red'},
                                {value: 'Heather_Royal', label: 'Heather Royal'},
                                {value: 'Heather_Sky', label: 'Heather Sky'},
                                {value: 'Heather_Pumpkin', label: 'Heather Pumpkin'},
                                {value: 'Solid_White', label: 'Solid White'},
                                {value: 'Solid_Black', label: 'Solid Black'},
                                {value: 'Other', label: 'Other'}];
          
          this.listOfOptions =  [{ value: 'Heather_Burgundy', label: 'Heather Burgundy' },
                                { value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                { value: 'Heather_Grape', label: 'Heather Grape' },
                                { value: 'Heather_Graphite', label: 'Heather Graphite' },
                                { value: 'Heather_Honey', label: 'Heather Honey' },
                                { value: 'Heather_Kelly', label: 'Heather Kelly' },
                                { value: 'Heather_Melon', label: 'Heather Melon' },
                                {value: 'Heather_Mil_Green', label: 'Heather Mil Green'},
                                {value: 'Heather_Mint_Julep', label: 'Heather Mint Julep'},
                                {value: 'Heather_Purple', label: 'Heather Purple'},
                                {value: 'Heather_Red', label: 'Heather Red'},
                                {value: 'Heather_Royal', label: 'Heather Royal'},
                                {value: 'Heather_Sky', label: 'Heather Sky'},
                                {value: 'Heather_Pumpkin', label: 'Heather Pumpkin'},
                                {value: 'Solid_White', label: 'Solid White'},
                                {value: 'Solid_Black', label: 'Solid Black'},
                                {value: 'Other', label: 'Other'}];

      }
      
      if(this.garmentType==='Youth Short Sleeve'){
          this.listOptions= [{ value: 'Heather_Burgundy', label: 'Heather Burgundy' },
                                { value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                { value: 'Heather_Grape', label: 'Heather Grape' },
                                { value: 'Heather_Honey', label: 'Heather Honey' },
                                { value: 'Heather_Melon', label: 'Heather Melon' },
                                {value: 'Heather_Mil_Green', label: 'Heather Mil Green'},
                                {value: 'Heather_Mint_Julep', label: 'Heather Mint Julep'},
                                {value: 'Heather_Red', label:'Heather Red'},
                                {value: 'Heather_Royal', label:'Heather Royal'},
                                {value: 'Heather_Sky', label: 'Heather Sky'},
                                {value: 'Solid_White', label: 'Solid White'},
                                {value: 'Solid_Black', label: 'Solid Black'},
                                {value: 'Other', label: 'Other'}];
          
          this.listOfOptions = [{ value: 'Heather_Burgundy', label: 'Heather Burgundy' },
                                { value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                { value: 'Heather_Grape', label: 'Heather Grape' },
                                { value: 'Heather_Honey', label: 'Heather Honey' },
                                { value: 'Heather_Melon', label: 'Heather Melon' },
                                {value: 'Heather_Mil_Green', label: 'Heather Mil Green'},
                                {value: 'Heather_Mint_Julep', label: 'Heather Mint Julep'},
                                {value: 'Heather_Red', label:'Heather Red'},
                                {value: 'Heather_Royal', label:'Heather Royal'},
                                {value: 'Heather_Sky', label: 'Heather Sky'},
                                {value: 'Solid_White', label: 'Solid White'},
                                {value: 'Solid_Black', label: 'Solid_Black'},
                                {value: 'Other', label: 'Other'}];
      }
      if(this.garmentType==='Long Sleeve'){
          this.listOptions= [{ value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                { value: 'Heather_Red', label: 'Heather Red' },
                                { value: 'Solid_Black', label: 'Solid Black' },
                                { value: 'Other', label: 'Other' }];
          
          this.listOfOptions = [{ value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                { value: 'Heather_Red', label: 'Heather Red' },
                                { value: 'Solid_Black', label: 'Solid Black' },
                                { value: 'Other', label: 'Other' }];
      }
      if(this.garmentType==='Hooded Fleece'){
          this.listOptions= [{ value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                {value: 'Heather_Red', label:'Heather Red'},
                                { value: 'Sand', label: 'Sand' },
                                { value: 'Sky', label: 'Sky' },
                                { value: 'Solid_Black', label: 'Solid Black' },
                                { value: 'Other', label: 'Other' }];
          
          this.listOfOptions = [{ value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                {value: 'Heather_Red', label:'Heather Red'},
                                { value: 'Sand', label: 'Sand' },
                                { value: 'Sky', label: 'Sky' },
                                { value: 'Solid_Black', label: 'Solid Black' },
                                { value: 'Other', label: 'Other' }];
      }
      if(this.garmentType==='Crewneck Fleece'){
          this.listOptions= [{ value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                {value: 'Heather_Red', label:'Heather Red'},
                                { value: 'Sky', label: 'Sky' },
                                { value: 'Other', label: 'Other' }];
          
          this.listOfOptions = [{ value: 'Heather_Charcoal', label: 'Heather Charcoal' },
                                { value: 'Heather_Denim', label: 'Heather Denim' },
                                {value: 'Heather_Red', label:'Heather Red'},
                                { value: 'Sky', label: 'Sky' },
                                { value: 'Other', label: 'Other' }];
      }
      console.log('listOptions',this.listOptions);
      console.log('listOfOptions',this.listOfOptions);
  }

    handleChange(event) {
        this.value=event.target.value;
        console.log('event',event)
        this.selValues = event.target.value;
        let selectedLabel = this.listOptions.find(option => option.value === event.detail.value);
        if(!this.allValues.includes(selectedLabel.value))
          this.allValues.push(selectedLabel.value);
        if(!this.allLabels.includes(selectedLabel.label))
          this.allLabels.push(selectedLabel.label);
        
        this.modifyOptions();
        
   }

   handleRemove(event){
     this.value='';
     const removedValue = event.target.name;
     let selectedLabel = this.listOfOptions.find(option => option.label === event.detail.name);
     this.allLabels.splice(this.allLabels.indexOf(removedValue),1);
     this.allValues.splice(this.allValues.indexOf(selectedLabel.value),1);
     this.modifyOptions();
   }

   modifyOptions()
   {
     this.listOptions=this.listOfOptions.filter(elem=>{
       if(!this.allValues.includes(elem.value))
         return elem;
     });

     this.selectedValues= this.allLabels.join(';');
     console.log('@@this.selectedValues::',this.selectedValues);
   }

}