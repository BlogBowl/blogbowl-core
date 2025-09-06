import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = ['link'];

    connect() {}

    closeModal(e) {
        const modal = e.target.closest('turbo-frame');

        modal.innerHTML = '';
        modal.removeAttribute('src');
        modal.removeAttribute('complete');
    }

    async remove(e) {
        e.preventDefault();
        const linkId = e.currentTarget.dataset.linkId;
        const authorId = window.location.pathname.split('/')[3];

        const link = this.element.querySelector(
            `[data-links-target="link"][data-id="${linkId}"]`,
        );

        link.classList.add('hidden');

        try {
            await fetch(`/page/authors/${authorId}/links/${linkId}`, {
                method: 'DELETE',
                headers: {
                    'X-CSRF-Token': document.querySelector(
                        '[name="csrf-token"]',
                    ).content,
                },
            });
        } catch (e) {
            link.classList.remove('hidden');
            console.error(e);
        }
    }
}
