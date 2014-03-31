require "service/connection/version"
require "authorizator/client"
require "service/connection/talking_token"

module Service

  # An instance of this class is the way an ideas4all service call endpoints of another one.
  # It provides get, post, put, patch, headers, delete... methods to access a called service endpoints. Authorization
  # and security concerns are transparent to the caller service.
  class Connection
    # Hashes of info of the two services talking via this connection.
    attr_accessor :caller_service, :called_service

    # Initializes a ServiceConnection
    #
    # @param [Hash] caller_service_data including at least :client_id and :client_secret
    # @param [Hash] called_service_data including at least :site
    def initialize(services_data = {})
      @caller_service = services_data[:caller_service_data]
      @called_service = services_data[:called_service_data]
      check_services_data!
    end

    # Make a GET request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#get
    def get(path, opts = {}, &block)
      renewing_talking_token_if_needed do
        talking_token.get(path, opts, &block)
      end.parsed
    end

    # Make a POST request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#post
    def post(path, opts = {}, &block)
      renewing_talking_token_if_needed do
        talking_token.post(path, opts, &block)
      end.parsed
    end

    # Make a PUT request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#put
    def put(path, opts = {}, &block)
      renewing_talking_token_if_needed do
        talking_token.put(path, opts, &block)
      end.parsed
    end

    # Make a PATCH request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#patch
    def patch(path, opts = {}, &block)
      renewing_talking_token_if_needed do
        talking_token.patch(path, opts, &block)
      end.parsed
    end

    # Make a DELETE request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#delete
    def delete(path, opts = {}, &block)
      renewing_talking_token_if_needed do
        talking_token.delete(path, opts, &block)
      end.parsed
    end


    private

      # Properties :client_id and :client_secret of the caller service.
      #
      # @returns [Hash] a hash of caller service credential values
      def caller_service_credentials
        {:client_id     => caller_service[:client_id],
         :client_secret => caller_service[:client_secret]}
      end

      # The client to be able to access the Authorizator service.
      #
      # @returns [Authorizator::Client] instance.
      def authorizator_client
        @authorizator_client ||= Authorizator::Client.new(caller_service_credentials)
      end

      # The Service::Connection::TalkingToken instance from where to access the target service endpoints in a secured way.
      # Calls the Authorizator service to get the currently valid talking token in case it was expired? or not exist.
      #
      # @return [OAuth2::AccessToken] instance.
      def talking_token
        return @talking_token if (@talking_token and !@talking_token.expired?)
        @talking_token = TalkingToken.from_hash(client, authorizator_client.talking_token)
      end

      # The OAuth2::Client instance the talking token needs to access called service endpoints.
      #
      # @returns [OAuth2::Client] instance.
      def client
        @client = OAuth2::Client.new(caller_service[:client_id],
                                     caller_service[:client_secret],
                                     :site         => called_service[:site],
                                     :raise_errors => false)
      end

      # Calls the given block and return the result if no problems found.
      # If the response of the block includes an invalid_access_token error, remove the current one and
      #   retry the block call, so the access_token will get renewed when calling #access_token again.
      def renewing_talking_token_if_needed(&block)
        resp = block.call
        if (resp.error and resp.error.code == "Invalid Talking Token")
          @talking_token = nil
          resp = block.call
        end
        resp
      end

      def check_services_data!
        caller_service.fetch(:client_id)     rescue raise("Must provide :caller_service_data hash including :client_id k-v pair")
        caller_service.fetch(:client_secret) rescue raise("Must provide :caller_service_data hash including :client_secret k-v pair")
        called_service.fetch(:site)          rescue raise("Must provide :called_service_data hash including :site k-v pair")
      end

  end

end
