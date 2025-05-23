// Helper functions to handle space-separated class names
function addClassList(element, classesString) {
    if (!classesString) return;
    const classes = classesString.split(' ');
    classes.forEach(cls => {
        if (cls) element.classList.add(cls);
    });
}

function removeClassList(element, classesString) {
    if (!classesString) return;
    const classes = classesString.split(' ');
    classes.forEach(cls => {
        if (cls) element.classList.remove(cls);
    });
}

document.addEventListener('turbo:load', function () {
    const tableOfContents = document.getElementById('table-of-contents');

    if (!tableOfContents) return;

    const headings = document.querySelectorAll('h2, h3');
    const tocItems = tableOfContents
        ? tableOfContents.querySelectorAll('li')
        : [];

    function setActiveItem() {
        let currentSection = '';
        headings.forEach(heading => {
            const rect = heading.getBoundingClientRect();
            if (rect.top <= 50) {
                currentSection = '#' + heading.id;
            }
        });

        tocItems.forEach(item => {
            const link = item.querySelector('a');
            if (link) {
                const href = link.getAttribute('href');
                const itemActiveClass = item.dataset.activeClass;
                const linkActiveClass = link.dataset.activeClass;
                const linkInactiveClass = link.dataset.inactiveClass;

                if (href === currentSection) {
                    if (itemActiveClass) addClassList(item, itemActiveClass);
                    if (linkActiveClass) addClassList(link, linkActiveClass);
                    if (linkInactiveClass)
                        removeClassList(link, linkInactiveClass);
                } else {
                    if (itemActiveClass) removeClassList(item, itemActiveClass);
                    if (linkActiveClass) removeClassList(link, linkActiveClass);
                    if (linkInactiveClass)
                        addClassList(link, linkInactiveClass);
                }
            }
        });
    }

    if (tableOfContents) {
        tocItems.forEach(item => {
            const link = item.querySelector('a');

            if (!link) return;

            link.addEventListener('click', function (e) {
                e.preventDefault();
                const targetId = this.getAttribute('href').substring(1);
                const targetElement = document.getElementById(targetId);
                if (targetElement) {
                    targetElement.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start',
                    });
                    history.pushState(null, null, `#${targetId}`);
                }
            });
        });

        window.addEventListener('scroll', setActiveItem);
        setActiveItem();
    }
});
