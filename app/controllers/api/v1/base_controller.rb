module API
  module V1
    class BaseController < ActionController::API
      include Apipie::DSL
      include API::V1::Concerns::APIResponse

      before_action :authenticate_request

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid do |e|
        render_error(e.record.errors)
      end

      attr_reader :current_user, :current_workspace

      private

      def authenticate_request
        header = request.headers["Authorization"]
        header = header.split(" ").last if header
        token = APIToken.find_by(token: header)
        if token
          token.touch(:last_used_at)
          @current_user = token.user
          @current_workspace = token.workspace
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def not_found
        render json: { error: "Not found" }, status: :not_found
      end

      # Accept either wrapped payloads ({ post: {...} }) or flat JSON bodies.
      # When Rails auto-wraps a flat JSON body it only includes DB columns, leaving
      # virtual attributes (e.g. content_md) at the top level. We merge top-level
      # permitted params into the nested ones so nothing gets silently dropped.
      def permit_resource_params(resource_key, *filters)
        if params[resource_key].is_a?(ActionController::Parameters)
          top_level = params.permit(*filters)
          params.require(resource_key).permit(*filters).merge(top_level)
        else
          params.permit(*filters)
        end
      end
    end
  end
end
