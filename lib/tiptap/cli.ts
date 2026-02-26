import { parseToTipTapJson, parseToTipTapHtml } from './tiptap';

const [,, command] = process.argv;

async function main() {
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk);
  }
  const input = Buffer.concat(chunks).toString('utf8');

  try {
    let result: any;

    switch (command) {
      case 'html-to-json':
        result = parseToTipTapJson(input);
        break;
      case 'json-to-html':
        result = parseToTipTapHtml(JSON.parse(input));
        break;
      default:
        console.error(JSON.stringify({ success: false, error: `Unknown command: ${command}` }));
        process.exit(1);
    }

    console.log(JSON.stringify({ success: true, data: result }));
  } catch (error: any) {
    console.error(JSON.stringify({ success: false, error: error.message }));
    process.exit(1);
  }
}

main();
