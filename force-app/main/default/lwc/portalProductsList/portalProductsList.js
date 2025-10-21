import { api, LightningElement } from 'lwc';
import getOrderProducts from '@salesforce/apex/PortalSiteController.getOrderProds';

export default class PortalProductsList extends LightningElement {
    @api recordId;
    productList=[];

    pageData=[];
    pageNumber = 0;
    startRange=0;
    endRange=0;
    totalProds = 0;
    ShowMyProducts = false;

    connectedCallback() {
        getOrderProducts({orderId: this.recordId})
            .then((result) => {
                let prodList = result;
                this.productList = prodList.map( (data, index) => ({...data, URL:`/portal/s/portal-my-order/${prodList[index].Id}`}) );
                console.log('@@@productList', this.productList);

                if(this.productList.length > 0){
                    this.totalProds = this.productList.length;
                    this.ShowMyProducts = true;
                    this.updatePage();
                }
            })
            .catch((error) => {
                console.log('Error is', error); 
            });
    }

    // Set current page state
    updatePage() {
        this.pageData = this.productList.slice(this.pageNumber*10, this.pageNumber*10+10);
        this.startRange = this.pageNumber*10 + 1;
        this.endRange = this.pageNumber*10 + 10;
        if(this.endRange > this.totalProds)
            this.endRange = this.totalProds;
        console.log('this.pageData ', this.pageData);
    }

    // Back a page
    previous() {
        this.pageNumber = Math.max(0, this.pageNumber - 1);
        this.updatePage();
    }
    // Back to the beginning
    first() {
    this.pageNumber = 0;
    this.updatePage();
    }

    // Forward a page
    next() {
        this.pageNumber = Math.min(Math.floor((this.productList.length-1)/10), this.pageNumber + 1);
        this.updatePage();
    }

    // Forward to the end
    last() {
        this.pageNumber = Math.floor((this.productList.length-1)/10);
        this.updatePage();
    }
}