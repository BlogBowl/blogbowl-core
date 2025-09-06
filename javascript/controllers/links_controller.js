import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = ['link'];
    static values = { slug: String };

    connect() {
        this.sortLinks();
    }

    onUp({ target }) {
        const link = this.linkTargets.find(l => l.contains(target));
        const linkIdx = this.linkTargets.findIndex(l => l.contains(target));
        if (!link || link.dataset.sort === '0') {
            return;
        }
        const previousLink = this.linkTargets[linkIdx - 1];
        link.dataset.sort = linkIdx - 1;
        previousLink.dataset.sort = linkIdx;

        this.sortLinks();
    }

    onDown({ target }) {
        const link = this.linkTargets.find(l => l.contains(target));
        const linkIdx = this.linkTargets.findIndex(l => l.contains(target));
        if (
            !link ||
            link.dataset.sort === (this.linkTargets.length - 1).toString()
        ) {
            return;
        }
        const nextLink = this.linkTargets[linkIdx + 1];
        link.dataset.sort = linkIdx + 1;
        nextLink.dataset.sort = linkIdx;

        this.sortLinks();
    }

    sortLinks() {
        const links = Array.from(this.linkTargets);

        links.sort((a, b) => {
            return parseInt(a.dataset.sort, 10) - parseInt(b.dataset.sort, 10);
        });

        this.element.innerHTML = '';
        links.forEach((link, idx) => {
            link.dataset.sort = idx.toString();
            link.querySelector('input[name="links[][order]"]').value =
                idx.toString();
            this.element.appendChild(link);
        });
    }

    closeModal(e) {
        const modal = e.target.closest('turbo-frame');

        modal.innerHTML = '';
        modal.removeAttribute('src');
        modal.removeAttribute('complete');
    }

    async remove(e) {
        e.preventDefault();
        const link = this.linkTargets.find(l => l.contains(e.target));
        const linkId = link.dataset.id;

        link.classList.add('hidden');

        try {
            await fetch(`/pages/${this.slugValue}/settings/links/${linkId}`, {
                method: 'DELETE',
                headers: {
                    'X-CSRF-Token': document.querySelector(
                        '[name="csrf-token"]',
                    ).content,
                },
            });
            this.sortLinks();
        } catch (e) {
            link.classList.remove('hidden');
            console.error(e);
        }
    }
}
