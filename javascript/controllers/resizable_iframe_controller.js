import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        window.addEventListener('message', this.handleMessage.bind(this), false);
    }

    disconnect() {
        window.removeEventListener('message', this.handleMessage.bind(this), false);
    }

    handleMessage(event) {
        if (event.isTrusted && event.data.type === 'umami:loaded' && event.origin === window.cfg.analyticsHost) {
            this.resize(event.data.height)
        }
    }

    resize(value) {
        this.element.height = (value + 20) + 'px';
        const heightClass = new Array(...this.element.classList.values()).find((value) => value.startsWith('h-'));
        if (heightClass) {
            this.element.classList.remove(heightClass);
        }
    }
}
