import { api, LightningElement } from 'lwc';
import getMyOrders from '@salesforce/apex/PortalSiteController.getMyOrders';
import Id from '@salesforce/user/Id';

export default class PortalOpenOrdersList extends LightningElement {
    @api variant;

    tableHeader;
    myOrderList=[];
    pageData=[];
    pageNumber = 0;
    startRange=0;
    endRange=0;
    totalOrders = 0;
    portalUserId = Id;

    showPendingOrders=false;
    showCompletedOrders=false;
    showOpenOrders=false;
    showInvoiceOrders=false;
    showDataTable=false;
    noDataMsg='';

    connectedCallback() {
        
        getMyOrders({userId: this.portalUserId, type: this.variant})
            .then((result) => {
                let ordersList = JSON.parse(JSON.stringify(result).replace(/Quote_Request/g, 'Quote Request'));
                this.myOrderList = ordersList.map( (data, index) => ({...data, URL:`/portal/s/detail/${ordersList[index].Id}`}) );
                console.log('@@@myOrderList', this.myOrderList);

                if(this.myOrderList.length > 0){
                    this.showDataTable = true;
                    this.totalOrders = this.myOrderList.length;
                    this.updatePage();
                }
            })
            .catch((error) => {
                console.log('Error is', error); 
            });
        
        if(this.variant == 'Pending'){
            this.tableHeader = 'Pending Steps';
            this.showPendingOrders=true;
            this.showCompletedOrders=false;
            this.showOpenOrders=false;
            this.showInvoiceOrders=false;
            this.noDataMsg="You're all caught up! Start a new order using the button below!";
        }
        else if(this.variant == 'Completed'){
            this.tableHeader = 'Completed Order List';
            this.showPendingOrders=false;
            this.showCompletedOrders=true;
            this.showOpenOrders=false;
            this.showInvoiceOrders=false;
            this.noDataMsg="Nothing to show here yet. Once your first order is complete, you can see your full order history here.";
        }
        else if(this.variant == 'Invoice'){
            this.tableHeader = 'Pay Invoices Here!';
            this.showPendingOrders=false;
            this.showCompletedOrders=false;
            this.showOpenOrders=false;
            this.showInvoiceOrders=true;
            this.noDataMsg="Nothing to show here yet. Once your invoice has been created you will be able to open it and pay.";
        }
        else{
            this.tableHeader = 'Open Order List';
            this.showPendingOrders=false;
            this.showCompletedOrders=false;
            this.showOpenOrders=true;
            this.showInvoiceOrders=false;
            this.noDataMsg="No open orders at the moment. Start a new project today. We're ready to serve!";
        }
    }

    // Set current page state
    updatePage() {
        console.log('Inside updatePage');
        this.pageData = this.myOrderList.slice(this.pageNumber*10, this.pageNumber*10+10);
        this.startRange = this.pageNumber*10 + 1;
        this.endRange = this.pageNumber*10 + 10;
        if(this.endRange > this.totalOrders)
            this.endRange = this.totalOrders;
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
        this.pageNumber = Math.min(Math.floor((this.myOrderList.length - 1)/10), this.pageNumber + 1);
        this.updatePage();
    }

    // Forward to the end
    last() {
        this.pageNumber = Math.floor((this.myOrderList.length - 1)/10);
        this.updatePage();
    }
}