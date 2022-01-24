# frozen_string_literal: true

module Error
  # Models a generic custom error (project defined errors)
  class CustomError < StandardError
    attr_reader :status, :error, :message

    def initialize(error = nil, status = nil, message = nil)
      @error = error || 500
      @status = status || :internal_server_error
      @message = message || 'Something went wrong'
    end
  end
end
