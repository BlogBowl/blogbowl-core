require 'json'
require 'open3'

class TiptapConverter
  class ConversionError < StandardError; end

  TIPTAP_PATH = ENV.fetch('TIPTAP_PARSER_PATH', File.expand_path('../../../../parse-tiptap-blogbowl', __dir__)).freeze
  TIMEOUT_SECONDS = 30

  class << self
    def html_to_json(html)
      execute_conversion('html-to-json', html)
    end

    def json_to_html(json)
      json_string = json.is_a?(String) ? json : json.to_json
      execute_conversion('json-to-html', json_string)
    end

    private

    def execute_conversion(command, input)
      stdout, stderr, status = Open3.capture3(
        'bun', 'run', 'cli.ts', command,
        stdin_data: input,
        chdir: TIPTAP_PATH
      )

      unless status.success?
        raise ConversionError, stderr.presence || "Conversion failed"
      end

      result = JSON.parse(stdout)
      result['success'] ? result['data'] : raise(ConversionError, result['error'])
    end
  end
end
