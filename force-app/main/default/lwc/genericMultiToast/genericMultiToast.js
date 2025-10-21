import { LightningElement, api } from 'lwc';

export function createToastMessage(name, body, render = true) {
    return { name, body, render }
}

export default class GenericMultiToast extends LightningElement {
    @api messages;

    hideMessage(event) {
        let msgKey = parseInt(event.target.dataset.id);
        let messages = JSON.parse(JSON.stringify(this.messages));
        messages[msgKey].render = false;
        this.dispatchEvent(new CustomEvent('change', { detail: messages }));
    }
}