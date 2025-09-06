import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "ownDomain", "ownDomainValue", "ownDomainLabel", "blogbowlSuffixLabel",
        "subfolder",
        "docsSection", "dnsDocsSection", "subfolderDocsSection"]

    connect() {
        this.handleSections();
    }

    onOwnDomainChange() {
        const isChecked = this.ownDomainTarget.checked
        if (isChecked) {
            this.blogbowlSuffixLabelTarget.classList.add("hidden")
        } else {
            this.blogbowlSuffixLabelTarget.classList.remove("hidden")
        }

        this.handleSections();
    }

    onOwnDomainValueChange() {
        this.handleSections();
    }

    onSubfolderChange() {
        this.handleSections();
    }

    handleSections() {
        const isSubfolderChecked = this.subfolderTarget.checked
        const isOwnDomainChecked = this.ownDomainTarget.checked

        if (!isOwnDomainChecked) {
            this.dnsDocsSectionTarget.classList.add("hidden")
        } else {
            this.dnsDocsSectionTarget.classList.remove("hidden")
        }

        if (isSubfolderChecked) {
            this.subfolderDocsSectionTarget.classList.remove("hidden")
        } else {
            this.subfolderDocsSectionTarget.classList.add("hidden")
        }

        this.ownDomainLabelTargets.forEach(l => l.textContent = this.getDomain())
    }

    getDomain() {
        if (this.ownDomainTarget.checked) {
            return this.ownDomainValueTarget.value
        }
        return `${this.ownDomainValueTarget.value}.blogbowl.app`
    }
}
