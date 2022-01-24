# frozen_string_literal: true

# Include this module in your controllers to add a generic error handling logic for your requests
module Error
  # Logic for handling errors in controllers
  module ErrorHandler
    # Wrapper for rescuing StandardErrors and CustomErrors in controller actions
    def self.included(clazz)
      clazz.class_eval do
        rescue_from StandardError do |standard_error|
          http_error_code = http_error_code(standard_error: standard_error)

          render_error(Error::CustomError.new(http_error_code,
                                              http_code_status(error_code: http_error_code), standard_error.to_s))
        end

        rescue_from CustomError do |custom_error|
          render_error(Error::CustomError.new(custom_error.error, custom_error.status, custom_error.message))
        end
      end
    end

    private

    # Logic to render Standard Errors
    #
    # @param error [StandardError] error to be returned as request response
    def render_error(error)
      render template: 'api/v1/error',
             status: error.status,
             locals: { code: error.error, status: error.status, message: error.message }
    end

    def http_error_code(standard_error:)
      ActionDispatch::ExceptionWrapper.status_code_for_exception(standard_error.class.name)
    end

    def http_code_status(error_code:)
      Rack::Utils::SYMBOL_TO_STATUS_CODE.key(error_code)
    end
  end
end
