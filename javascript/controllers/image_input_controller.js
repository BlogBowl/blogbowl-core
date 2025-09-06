import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["attached", "placeholder", "deleteToggle"]

    onDeleteToggleChanged() {
        const isChecked = this.deleteToggleTarget.checked;
        if (isChecked) {
            this.attachedTarget.classList.add("hidden")
            this.attachedTarget.classList.remove("block")

            this.placeholderTarget.classList.add("flex")
            this.placeholderTarget.classList.remove("hidden")
        } else {
            this.attachedTarget.classList.remove("hidden")
            this.attachedTarget.classList.add("block")

            this.placeholderTarget.classList.remove("flex")
            this.placeholderTarget.classList.add("hidden")
        }
    }
}
