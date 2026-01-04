require_relative 'concerns/api_response'

module API
  module V1
    class BaseController < ActionController::API
      include Apipie::DSL
      # include API::V1::APIResponse

      before_action :authenticate_request

      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      attr_reader :current_user, :current_workspace

      private

      def authenticate_request
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        token = APIToken.find_by(token: header)
        if token
          token.touch(:last_used_at)
          @current_user = token.user
          @current_workspace = token.workspace
        else
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def not_found
        render json: { error: 'Not found' }, status: :not_found
      end
    end
  end
end
