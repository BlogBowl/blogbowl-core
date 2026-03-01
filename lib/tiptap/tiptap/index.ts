// @ts-ignore: Found types but resolution failed
import { generateHTML, generateJSON } from '@tiptap/html/server';
import ExtensionKit from './extensions/extension-kit';
import { randomUUID } from 'crypto';

const addRandomIdsToHeaders = (html: string) => {
  return html.replace(/<h([1-6])([^>]*)>(.*?)<\/h\1>/g, (match, level, attrs, content) => {
    const randomId = randomUUID();
    return `<h${level}${attrs} id="${randomId}" data-toc-id="${randomId}">${content}</h${level}>`;
  });
};

const removeWhiteSpacesAndNewlines = (html: string) => {
  return html
    .replace(/\\n/g, '') // remove literal '\n'
    .replace(/>\s+</g, '><') // remove spaces/newlines between tags
    .replace(/\s{2,}/g, ' ');
};

export const parseToTipTapJson = (html: string) => {
  const preparedHtml = addRandomIdsToHeaders(removeWhiteSpacesAndNewlines(html));
  return generateJSON(preparedHtml, ExtensionKit());
};

export const parseToTipTapHtml = (json: Record<string, any>) => {
  return generateHTML(json, ExtensionKit());
};
