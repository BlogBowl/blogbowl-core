import {
  BlockquoteFigure,
  CharacterCount,
  Color,
  Column,
  Columns,
  Document,
  Dropcursor,
  Figcaption,
  Focus,
  FontFamily,
  FontSize,
  Heading,
  Highlight,
  HorizontalRule,
  ImageBlock,
  Link,
  Placeholder,
  Selection,
  StarterKit,
  Subscript,
  Superscript,
  Table,
  TableCell,
  TableHeader,
  TableRow,
  TaskItem,
  TaskList,
  TextAlign,
  TextStyle,
  TrailingNode,
  Typography,
  Underline,
} from './index';
import { ImageUpload } from './ImageUpload';
import { TableOfContentsNode } from './TableOfContentsNode';
import { ExtendedYoutube } from './ExtendedYoutube';

export const ExtensionKit = () => {
  return [
    Heading.configure({
      levels: [2, 3, 4, 5, 6],
    }),
    Document,
    Columns,
    TaskList,
    TaskItem.configure({
      nested: true,
    }),
    Column,
    Selection,
    HorizontalRule,
    // TweetEmbed,
    ExtendedYoutube.configure({
      controls: false,
      nocookie: true,
    }),
    StarterKit.configure({
      document: false,
      dropcursor: false,
      heading: false,
      horizontalRule: false,
      blockquote: false,
      // @ts-expect-error whatever
      history: true,
      codeBlock: false,
    }),
    TextStyle,
    FontSize,
    FontFamily,
    Color,
    TrailingNode,
    Link.configure({
      openOnClick: false,
    }),
    Highlight.configure({ multicolor: true }),
    Underline,
    CharacterCount.configure({ limit: 50000 }),
    TableOfContentsNode,
    ImageUpload.configure({
      // clientId: provider?.document?.clientID,
    }),
    ImageBlock,
    TextAlign.extend({
      addKeyboardShortcuts() {
        return {};
      },
    }).configure({
      types: ['heading', 'paragraph'],
    }),
    Subscript,
    Superscript,
    Table,
    TableRow,
    TableHeader,
    TableCell,
    Typography,
    Placeholder.configure({
      includeChildren: true,
      showOnlyCurrent: false,
      placeholder: () => '',
    }),
    Focus,
    Figcaption,
    BlockquoteFigure,
    Dropcursor.configure({
      width: 2,
      class: 'ProseMirror-dropcursor border-black',
    }),
  ];
};

export default ExtensionKit;
