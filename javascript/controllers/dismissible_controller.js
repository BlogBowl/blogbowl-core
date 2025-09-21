import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static values = { url: String };

    dismiss() {
        // Immediately hide the element for a snappy user experience
        this.element.style.transition =
            'opacity 300ms ease-out, transform 300ms ease-out';
        this.element.style.opacity = 0;
        this.element.style.transform = 'scale(0.95)';
        setTimeout(() => this.element.remove(), 300);

        // Send a request to the server to record the dismissal
        const csrfToken = document
            .querySelector("meta[name='csrf-token']")
            .getAttribute('content');

        fetch(this.urlValue, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken,
            },
        }).catch(error => {
            console.error('Failed to dismiss notice:', error);
            // Optional: handle the error, e.g., show the notice again
        });
    }
}
