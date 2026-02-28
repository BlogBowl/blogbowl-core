module API
  module V1
    class MiscController < BaseController
      skip_before_action :authenticate_request

      OPENAPI_SPEC_PATH = Rails.root.join("doc", "apidoc", "schema_swagger_json.json").freeze

      def openapi
        unless File.exist?(OPENAPI_SPEC_PATH)
          render json: { error: "OpenAPI spec not found. Run: bundle exec rake apipie:static_swagger_json" },
                 status: :not_found
          return
        end

        render json: File.read(OPENAPI_SPEC_PATH)
      end
    end
  end
end
