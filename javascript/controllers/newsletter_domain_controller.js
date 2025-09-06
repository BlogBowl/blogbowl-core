import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = [
        'ownDomainCheckbox',
        'domainInput',
        'domainDisplay',
        'verifyDocumentation',
    ];

    previousDomain = null;

    connect() {
        console.log('Registered controller');
    }

    onOwnDomainChange() {
        const isChecked = this.ownDomainCheckboxTarget.checked;

        if (isChecked) {
            const domainToSet = this.previousDomain ?? '';
            this.domainInputTarget.value = this.previousDomain ?? '';
            this.domainInputTarget.readOnly = false;
            this.setDomainDisplay(domainToSet);
            if (this.verifyDocumentationTarget) {
                this.verifyDocumentationTarget.classList.remove('hidden');
                this.verifyDocumentationTarget.scrollIntoView({
                    behavior: 'smooth',
                });
            }
        } else {
            if (!this.previousDomain && this.domainInputTarget.value !== '') {
                this.previousDomain = this.domainInputTarget.value;
            }
            const domainToSet = 'mail.blogbowl.io';
            this.domainInputTarget.value = domainToSet;
            this.domainInputTarget.readOnly = true;
            this.setDomainDisplay(domainToSet);
            if (this.verifyDocumentationTarget) {
                this.verifyDocumentationTarget.classList.add('hidden');
            }
        }

        // this.handleSections();
    }

    onDomainChange() {
        if (this.domainInputTarget.value) {
            this.setDomainDisplay(this.domainInputTarget.value);
        }
    }

    setDomainDisplay(domain) {
        let domainToSet = domain;
        if (domain === '') {
            domainToSet = 'example.com';
        }
        this.domainDisplayTarget.textContent = `@${domainToSet}`;
    }
}
