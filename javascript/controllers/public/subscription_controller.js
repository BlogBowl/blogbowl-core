import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    connect() {}

    closeModal(event) {
        event.preventDefault();
        const modal = document.getElementById('subscription_modal_dialog');
        if (modal) {
            modal.innerHTML = '';
            modal.classList.remove('modal-open');
            modal.id = 'subscription_message';
        }
    }
}
