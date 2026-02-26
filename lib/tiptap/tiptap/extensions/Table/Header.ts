import TiptapTableHeader from '@tiptap/extension-table-header';
import { mergeAttributes } from '@tiptap/core';

export const TableHeader = TiptapTableHeader.extend({
  content: 'block+',

  parseHTML() {
    return [{ tag: 'th' }];
  },

  renderHTML({ HTMLAttributes }) {
    return ['th', mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0];
  },

  addAttributes() {
    return {
      colspan: {
        default: 1,
      },
      rowspan: {
        default: 1,
      },
      colwidth: {
        default: null,
        parseHTML: (element) => {
          const colwidth = element.getAttribute('colwidth');
          const value = colwidth ? colwidth.split(',').map((item) => parseInt(item, 10)) : null;

          return value;
        },
      },
      style: {
        default: null,
      },
    };
  },
});

export default TableHeader;
