require 'service/connection/response'
require "service/connection/talking_token"

module Service
  class Connection


    module Request
      include Response

      private

        # The Service::Connection::TalkingToken instance from where to access the target service endpoints in a secured way.
        # Calls the Authorizator service to get a new valid talking token in case the stored is expired? or dont exist.
        #
        # @return [Service::Connection::TalkingToken] instance.
        def talking_token
          return @talking_token if (@talking_token and !@talking_token.expired?)
          @talking_token = TalkingToken.new(caller_service:caller_service, called_service:called_service, authorizator_service:authorizator_service)
        end

        # Calls the given block retrying once if the first response included an invalid talking token error.
        #
        # @return [OAuth2::Response] instance usually or whatever the block returns.
        def maybe_renewing_talking_token(&block)
          first_attempt_request(&block) or (renew_talking_token! and last_attempt_request(&block))
        end

          # Calls the given block once and returns response if it is not invalid.
          #
          # @return [Object] response or nil.
          def first_attempt_request(&block)
            resp = block.call
            resp unless invalid_talking_token_response?(resp)
          end

          # Removes the currently stored talking token to be renewed in the following call.
          #
          # @return [Boolean] true.
          def renew_talking_token!
            @talking_token = nil
            true
          end

          # Calls the given block the last time and returns response if it is not invalid.
          # Raises an error otherwise.
          #
          # @return [Object] response or raises an Exception.
          def last_attempt_request(&block)
            resp  = block.call
            error = invalid_talking_token_response?(resp)
            error ? raise(error) : resp
          end
    end


  end
end
