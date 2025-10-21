import { LightningElement, track, api } from 'lwc';

export default class CommListPagination extends LightningElement {

    @api numberOfPages = 1;
    @api currentPage = 1;
    @api isFirstPage;
    @api isFinalPage;

    firstHandler() {
        console.log('Clicked the previous button');
        this.dispatchEvent(new CustomEvent('first'));
    }

    previousHandler() {
        console.log('Clicked the previous button');
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextHandler() {
        console.log('Clicked the next button');
        this.dispatchEvent(new CustomEvent('next'));
    }

    lastHandler() {
        console.log('Clicked the next button');
        this.dispatchEvent(new CustomEvent('last'));
    }

}