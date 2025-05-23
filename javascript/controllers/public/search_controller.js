import { Controller } from '@hotwired/stimulus';

// TODO: Add turbo visit: https://turbo.hotwired.dev/reference/drive#turbodrivevisit
export default class extends Controller {
    static targets = ['input', 'searchIcon', 'searchContainer'];

    constructor(props) {
        super(props);
    }

    toggleSearch(event) {
        event.stopPropagation();
        this.searchIconTarget.classList.toggle('hidden');
        this.searchContainerTarget.classList.toggle('hidden');

        if (!this.searchContainerTarget.classList.contains('hidden')) {
            this.inputTarget.focus();
        } else {
            this.inputTarget.value = ''; // Clear input when closing
        }
    }

    submitSearch(event) {
        if (event.key === 'Enter') {
            this.performSearch();
        }
    }

    submitSearchClick(event) {
        event.preventDefault();
        this.performSearch();
    }

    performSearch() {
        const query = this.inputTarget.value.trim();
        if (query) {
            window.location.href = `/archive?s=${encodeURIComponent(query)}`;
        }
    }
}
