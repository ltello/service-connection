require "service/connection/version"
require "service/connection/request"

module Service

  # An instance of this class is the way an ideas4all service call endpoints of another one.
  # It provides get, post, put, patch, headers, delete... methods to access a called service's endpoints.
  # Authorization and security concerns are transparent to the caller service.
  # @see spec/README_FOR_* files for documentation of how to use this gem!.
  class Connection
    include Request

    # Hashes of info of the two services talking via this connection.
    attr_accessor :caller_service, :called_service, :authorizator_service

    # Initializes a ServiceConnection
    #
    # @param [Object] caller_service responding at least to :client_id and :client_secret
    # @param [Object] called_service responding at least to :site
    # @param [Object] authorizator_service responding at least to :site
    def initialize(caller_service:, called_service:, authorizator_service:)
      @caller_service       = caller_service
      @called_service       = called_service
      @authorizator_service = authorizator_service
      check_services_data!
    end

    # Show the Authorization header to be sent in the requests to the called service.
    #
    # @see OAuth2::AccessToken#headers
    def headers
      maybe_renewing_talking_token do
        talking_token.headers
      end
    end

    # Make a GET request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#get
    def get(path, opts = {}, &block)
      maybe_renewing_talking_token do
        talking_token.get(path, opts, &block)
      end.parsed
    end

    # Make a POST request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#post
    def post(path, opts = {}, &block)
      maybe_renewing_talking_token do
        talking_token.post(path, opts, &block)
      end.parsed
    end

    # Make a PUT request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#put
    def put(path, opts = {}, &block)
      maybe_renewing_talking_token do
        talking_token.put(path, opts, &block)
      end.parsed
    end

    # Make a PATCH request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#patch
    def patch(path, opts = {}, &block)
      maybe_renewing_talking_token do
        talking_token.patch(path, opts, &block)
      end.parsed
    end

    # Make a DELETE request with the talking token acting as access token.
    #
    # @see OAuth2::AccessToken#delete
    def delete(path, opts = {}, &block)
      maybe_renewing_talking_token do
        talking_token.delete(path, opts, &block)
      end.parsed
    end


    private

      # Checks that the provided service objects when initializing a Service::Connection, respond to some needed methods.
      #
      # Raises exceptions in case the check fails.
      def check_services_data!
        raise("Must provide caller_service client_id value")     unless caller_service.respond_to?(:client_id)
        raise("Must provide caller_service client_secret value") unless caller_service.respond_to?(:client_secret)
        raise("Must provide called_service site value")          unless called_service.respond_to?(:site)
        raise("Must provide authorizator_service site value")    unless authorizator_service.respond_to?(:site)
      end

  end

end
