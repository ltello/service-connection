require "oauth2"
require "authorizator/client"
require 'service/connection/response/error/talking_token'

module Service
  class Connection

    # The class to request and instantiate talking tokens from the Authorizator service, on behalf of a given service.
    # Once obtained and instantiated, a TalkingToken object can make requests for resources to another service,
    # via its verb methods: #get, #post, #put, ... #delete.
    class TalkingToken < ::OAuth2::AccessToken

      # The constructor of instances of this subclass is completely different from the superclass. So dont respond
      # to this superclass constructors: they will never work as intended by the superclass!.
      class << self
        undef_method :from_hash
        undef_method :from_kvform
      end

      # The services to dialog using this talking_token as authorization mechanism.
      attr_reader :caller_service, :called_service, :authorizator_service

      # A valid talking_token for the caller_service to be able to talk to the called service.
      #
      # @return [Service;;Connection::TalkingToken] instance through which access the called service api endpoints.
      def initialize(caller_service:, called_service:, authorizator_service:)
        @caller_service       = caller_service
        @called_service       = called_service
        @authorizator_service = authorizator_service
        talking_token_hash    = authorizator_client.talking_token
        check_received_talking_token_data!(talking_token_hash)
        super(client, talking_token_hash.delete('access_token'), talking_token_hash)
      end

      # The received scopes data of this TalkingToken instance.
      #
      # @return [String] of comma separated scopes of this instance.
      def scopes
        params['scope']
      end


      private

        # The predefined scope a talking token must have for a remote service to accept it and attend requests.
        TALKING_TOKEN_VALID_SCOPE = :service_mate.to_s

        # The client to be able to access the Authorizator service.
        #
        # @returns [Authorizator::Client] instance.
        def authorizator_client
          @authorizator_client ||= Authorizator::Client.new(caller_service: caller_service, authorizator_service: authorizator_service)
        end

        # The OAuth2::Client instance the talking token needs to make requests to called service endpoints.
        #
        # @returns [OAuth2::Client] instance.
        def client
          @client ||= OAuth2::Client.new(caller_service.client_id,
                                         caller_service.client_secret,
                                         :site         => called_service.site,
                                         :raise_errors => false)
        end

        # Raises a Response::Error::TalkingToken in case the received talking token data is invalid.
        #
        # @return [nil, Exception] depending the talking token data received is valid or not.
        def check_received_talking_token_data!(data)
          if token_data_blank?(data) or no_hash_token_data?(data) or no_access_token_data?(data) or miscoped_token_data?(data)
            raise Response::Error::TalkingToken.new(data:data)
          end
        end

          # Some data error-checking methods.
          def token_data_blank?(data);     !data or (data.respond_to?(:empty?) and data.empty?)               end
          def no_hash_token_data?(data);   !data.is_a?(Hash)                                                  end
          def no_access_token_data?(data); !data['access_token'].is_a?(String) or data['access_token'].empty? end
          def miscoped_token_data?(data);  data['scope'] != TALKING_TOKEN_VALID_SCOPE                         end
    end

  end
end
