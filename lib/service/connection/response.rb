module Service
  class Connection


    module Response

      private

        # The error codes a remote service reports when receiving a request with an invalid talking token.
        REMOTE_SERVICE_INVALID_TALKING_TOKEN_ERROR_CODES = ['invalid_token', 'invalid_talking_token']

        # Checks whether a response from the remote called service states a talking token error or not.
        #
        # @return [false, Object]: an error code or false if not invalid response.
        def invalid_talking_token_response?(resp)
          REMOTE_SERVICE_INVALID_TALKING_TOKEN_ERROR_CODES.each do |code|
            return code if resp.headers['www-authenticate'] =~ Regexp.new(code)
          end if resp.respond_to?(:headers)
          return false unless (resp.respond_to?(:error) and resp.error)
          return resp.error.code if REMOTE_SERVICE_INVALID_TALKING_TOKEN_ERROR_CODES.include?(resp.error.code)
          false
        end
    end


  end
end
