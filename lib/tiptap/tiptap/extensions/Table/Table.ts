import {Table as TipTapTable} from '@tiptap/extension-table';
import {mergeAttributes} from '@tiptap/core';

export const Table = TipTapTable.extend({
    parseHTML() {
        return [
            {
                tag: 'table',
                preserveWhitespace: 'full',
            },
        ];
    },

    renderHTML({HTMLAttributes}) {
        return ['table', mergeAttributes(HTMLAttributes), ['tbody', 0]];
    },
}).configure({
    resizable: true,
    lastColumnResizable: false,
});

export default Table;
