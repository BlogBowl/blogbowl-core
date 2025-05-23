window.checkTweets = function () {
    const tweetElements = document.querySelectorAll('twitter');

    if (!window?.twttr || !tweetElements.length) {
        return;
    }

    tweetElements.forEach(function (element) {
        const url = element.getAttribute('url');
        const tweetId = url.match(/\/status\/(\d+)/)[1];

        window.twttr.widgets
            .createTweet(tweetId, element, {
                conversation: 'none',
                cards: 'hidden',
                linkColor: '#cc0000',
                theme: 'light',
            })
            .then(function (el) {
                // Optionally, you can remove the original <twitter> element and replace it with the rendered tweet
                if (el) {
                    element.parentNode.replaceChild(el, element);
                }
            });
    });
};
