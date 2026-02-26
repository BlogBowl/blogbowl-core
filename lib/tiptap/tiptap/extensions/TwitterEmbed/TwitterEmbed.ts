// @ts-nocheck
import { nodePasteRule } from '@tiptap/react';
import { mergeAttributes, Node } from '@tiptap/core';

declare module '@tiptap/core' {
  interface Commands<ReturnType> {
    TweetEmbed: {
      /**
       * Open a generic modal with a specific type
       */
      insertTweet: (url: string) => ReturnType;
    };
  }
}

declare global {
  interface Window {
    twttr: any;
  }
}

export const TweetEmbed = Node.create({
  name: 'twitter',

  group: 'block',

  atom: true,

  draggable: true,

  isolating: true,

  selectable: false,

  marks: '',

  addPasteRules() {
    const twitterUrl = /^https:\/\/(twitter\.com|x\.com)\/.*\/status\/.*/g;

    return [
      nodePasteRule({
        find: twitterUrl,
        type: this.type,
        getAttributes: (match) => {
          return { url: match.input };
        },
      }),
    ];
  },

  addAttributes() {
    return {
      url: {
        default: 'https://twitter.com/vercel/status/1683920951807971329',
      },
    };
  },

  parseHTML() {
    return [
      {
        tag: 'twitter',
      },
    ];
  },

  renderHTML({ HTMLAttributes }) {
    return ['twitter', mergeAttributes(HTMLAttributes)];
  },

  addCommands() {
    return {
      insertTweet:
        (url) =>
        ({ commands }) => {
          return commands.insertContent({
            type: this.name,
            attrs: { url },
          });
        },
    };
  },

  addNodeView() {
    return null;
  },
});
