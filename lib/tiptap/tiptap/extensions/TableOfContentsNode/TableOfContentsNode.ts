import { Node, NodeViewRendererProps } from '@tiptap/core';

declare module '@tiptap/core' {
  interface Commands<ReturnType> {
    tableOfContentsNode: {
      insertTableOfContents: () => ReturnType;
    };
  }
}

export const TableOfContentsNode = Node.create({
  name: 'tableOfContentsNode',
  group: 'block',
  atom: true,
  selectable: true,
  draggable: true,
  inline: false,

  parseHTML() {
    return [
      {
        tag: 'div[data-type="table-of-content"]',
      },
    ];
  },

  renderHTML({ HTMLAttributes }) {
    return ['div', { ...HTMLAttributes, 'data-type': 'table-of-content' }];
  },

  addCommands() {
    return {
      insertTableOfContents:
        () =>
        ({ commands }) => {
          return commands.insertContent({
            type: this.name,
          });
        },
    };
  },
});
