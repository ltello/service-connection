require "service/connection/version"
require "authorizator/client"
require "service/connection/talking_token"

module Service

  # An instance of this class is the way an ideas4all service call endpoints of another one.
  # It provides get, post, put, patch, headers, delete... methods to access a called service's endpoints.
  # Authorization and security concerns are transparent to the caller service.
  class Connection

    # The error codes a remote service reports when receiving a request with an invalid talking token.
    REMOTE_SERVICE_INVALID_TALKING_TOKEN_ERROR_CODES = ['invalid_token', 'invalid_talking_token']

    # Hashes of info of the two services talking via this connection.
    attr_accessor :caller_service, :called_service, :authorizator_service

    # Initializes a ServiceConnection
    #
    # @param [Object] caller_service responding at least to :client_id and :client_secret
    # @param [Object] called_service responding at least to :site
    # @param [Object] authorizator_service
    def initialize(caller_service:, called_service:, authorizator_service:)
      @caller_service       = caller_service
      @called_service       = called_service
      @authorizator_service = authorizator_service
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

      # The client to be able to access the Authorizator service.
      #
      # @returns [Authorizator::Client] instance.
      def authorizator_client
        @authorizator_client ||= Authorizator::Client.new(caller_service: caller_service, authorizator_service: authorizator_service)
      end

      # The Service::Connection::TalkingToken instance from where to access the target service endpoints in a secured way.
      # Calls the Authorizator service to get ta new valid talking token in case the stored is expired? or dont exist.
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
        @client = OAuth2::Client.new(caller_service.client_id,
                                     caller_service.client_secret,
                                     :site         => called_service.site,
                                     :raise_errors => false)
      end

      # Calls the given block and return the result if no problems found.
      # If the response of the block includes an invalid_access_token error, remove the current one and
      #   retry the block call, so the access_token will get renewed when calling #access_token again.
      def renewing_talking_token_if_needed(&block)
        resp = block.call
        if invalid_remote_reponse?(resp)
          @talking_token = nil
          resp = block.call
          error = invalid_remote_reponse?(resp)
          raise(error) if error
        end
        resp
      end

        def invalid_remote_reponse?(resp)
          return false unless (resp.respond_to?(:error) and resp.error)
          return resp.error.code if REMOTE_SERVICE_INVALID_TALKING_TOKEN_ERROR_CODES.include?(resp.error.code)
          false
        end

      # Checks that the provided service objects when initializing a Service::Connection, respond to some needed methods.
      #
      # Raises exceptions in case the check fails.
      def check_services_data!
        raise("Must provide caller_service client_id value")     unless caller_service.respond_to?(:client_id)
        raise("Must provide caller_service client_secret value") unless caller_service.respond_to?(:client_secret)
        raise("Must provide called_service site value")          unless called_service.respond_to?(:site)
        raise("Must provide authorizator_service")               unless authorizator_service
      end

  end

end
