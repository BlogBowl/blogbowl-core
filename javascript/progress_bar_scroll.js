// TODO: Can we do it in tailwind?
document.addEventListener('turbo:load', function () {
    const progressBar = document.getElementById('progress-bar');

    function updateProgressBar() {
        if (!progressBar) {
            return;
        }
        const scrollTop =
            document.documentElement.scrollTop || document.body.scrollTop;
        const scrollHeight =
            document.documentElement.scrollHeight -
            document.documentElement.clientHeight;
        const scrolled = (scrollTop / scrollHeight) * 100;
        if (scrolled === 0) {
            progressBar.style.width = scrolled;
        } else {
            progressBar.style.width = scrolled + '%';
        }
    }

    window.addEventListener('scroll', updateProgressBar);
});
