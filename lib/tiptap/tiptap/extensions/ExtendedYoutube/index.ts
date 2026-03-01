import { Youtube as DefaultYoutube } from '@tiptap/extension-youtube';

export const ExtendedYoutube = DefaultYoutube.extend({
  addAttributes() {
    return {
      ...this.parent?.(),
      videoId: {
        default: null,
      },
      src: {
        default: null,
      },
    };
  },

  parseHTML() {
    return [
      {
        tag: 'iframe[src*="/embed/"]',
        getAttrs: (node) => {
          if (!node) return false;

          const src = node.getAttribute('src');
          const match = src?.match(/youtube(?:-nocookie)?\.com\/embed\/([\w-]+)/);

          if (!match) return false;

          return {
            videoId: match[1],
            src: `https://www.youtube.com/watch?v=${match[1]}`,
          };
        },
      },
    ];
  },

  renderHTML({ HTMLAttributes }) {
    const videoId = HTMLAttributes.videoId;
    const src = `https://www.youtube-nocookie.com/embed/${videoId}`;

    return [
      'div',
      { 'data-youtube-video': '' },
      [
        'iframe',
        {
          src,
          width: 560,
          height: 315,
          frameborder: '0',
          allowfullscreen: 'true',
          allow: 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture',
        },
      ],
    ];
  },
});
