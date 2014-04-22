require 'spec_helper'

describe "The service-connection gem is the messenger among ideas4all services. It:
              - allows the caller service to access the called service's endpoints.
              - transport protocol is transparent for the caller.
              - the communication is secured via Oauth2 protocol and ideas4all authorized talking-token mechanism

          To use the gem, instantiate the class Service::Connection:

              ac = Service::Connection.new(caller_service:caller_service, called_service:called_service, authorizator_service:authorizator_service)

          where caller_service must be an object responding to #client_id and #client_secret and
          called_service and authorizator_service must be objects responding to #site.
          - the client_id and client_secret values returned by these methods must be the ones assigned to a registered
          client_application (service) in the Authorizator service.
          - the site value must be the complete url to the corresponding service.

          Once a Service::Connection instance is ready, use it to call methods of its public interface to either get
          info of the connection itself or get access to the called service api in a transparent and secure way, using
          the http known verbs:

             ac.caller_service                        #=> the same caller_service object passed when instantiating ac
             ac.authorizator_service                  #=> the same authorizator_service object passed when instantiating ac
             ac.put('/users/7', params:{name:'Pepe'}) #=> make a GET request to 'called_service_site/users/7'" do
  it "" do
    expect(true).to be_true
  end
end
