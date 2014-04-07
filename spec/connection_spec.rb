require 'spec_helper'

describe "The service-connection gem is the messenger among ideas4all services. It:
              - allows the caller service to access the called service's endpoints.
              - transport protocol is transparent for the caller.
              - the communication is secured via Oauth2 protocol and ideas4all authorized talking-token mechanism." do

  context "Service::Connection: this class access target endpoints carrying params." do
    let(:service_class)                      {Struct.new(:client_id, :client_secret, :site)}
    let(:valid_caller_service_client_id)     {'12345'}
    let(:valid_caller_service_client_secret) {'67890'}
    let(:valid_caller_service_site)          {'https://caller_service.ideas4all.com'}
    let(:caller_service)                     {service_class.new(valid_caller_service_client_id, valid_caller_service_client_secret, nil)}
    let(:valid_called_service_client_id)     {'3458686675'}
    let(:valid_called_service_client_secret) {'671237685234890'}
    let(:valid_called_service_site)          {'https://called_service.ideas4all.com'}
    let(:called_service)                     {service_class.new(nil, nil, valid_called_service_site)}
    let(:authorizator_service_site)          {'http://localhost:3000'}
    let(:authorizator_service)               {service_class.new(nil, nil, authorizator_service_site)}
    let(:authorizator_client)                {Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)}

    # let(:authorizator_client)         {Authorizator::Client.new(valid_caller_service_credentials)}
    # let(:authorizator_service_site)   {Authorizator::Client::AUTHORIZATOR_SERVICE_SITE}
    # let(:valid_access_token_value)    {'567890123456789012345678901234567890'}
    # let(:access_token_type)           {'bearer'}
    # let(:access_token_expires_in)     {'500'}
    # let(:access_token_scope)          {'myself'}
    # let(:valid_access_token_data)     {{'access_token' => valid_access_token_value,
    #                                     'token_type'   => access_token_type,
    #                                     'expires_in'   => access_token_expires_in,
    #                                     'scope'        => access_token_scope}}
    # let(:valid_talking_token_value)   {'1234567890123456789012345678901234567890'}
    # let(:talking_token_type)          {'bearer'}
    # let(:talking_token_expires_in)    {'1000'}
    # let(:talking_token_scope)         {'service_mate'}
    # let(:valid_talking_token_data)    {{'access_token' => valid_talking_token_value,
    #                                     'token_type'   => talking_token_type,
    #                                     'expires_in'   => talking_token_expires_in,
    #                                     'scope'        => talking_token_scope}}
    # let(:new_client_application)      {double(:client_credentials => double(:get_token => valid_access_token_data))}

    let(:service_connection) {Service::Connection.new(caller_service:       caller_service,
                                                      called_service:       called_service,
                                                      authorizator_service: authorizator_service)}
    context "- Instantiation:" do
      it "To create a Service::Connection instance you must provide three objects: :caller_service and :called_service and :authorizator_service." do
        expect(service_connection).to be_a(Service::Connection)
      end

      it "An error will be raised otherwise." do
        expect{Service::Connection.new}.to raise_error
        expect{Service::Connection.new(caller_service: caller_service)}.to raise_error(ArgumentError)
        expect{Service::Connection.new(called_service: called_service)}.to raise_error(ArgumentError)
        expect{Service::Connection.new(caller_service: caller_service, called_service: called_service)}.to raise_error(ArgumentError)
        expect{Service::Connection.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error(ArgumentError)
        expect{Service::Connection.new(called_service: called_service, authorizator_service: authorizator_service)}.to raise_error(ArgumentError)
      end

      it "<caller_service> object must respond to #client_id..." do
        invalid_service_class = Struct.new(:client_secret, :site)
        caller_service        = invalid_service_class.new(valid_caller_service_client_secret, valid_caller_service_site)
        expect {Service::Connection.new(caller_service:       caller_service,
                                        called_service:       called_service,
                                        authorizator_service: authorizator_service)}.to raise_error
      end

      it "...and :client_secret." do
        invalid_service_class = Struct.new(:client_id, :site)
        caller_service        = invalid_service_class.new(valid_caller_service_client_id, valid_caller_service_site)
        expect {Service::Connection.new(caller_service:       caller_service,
                                        called_service:       called_service,
                                        authorizator_service: authorizator_service)}.to raise_error
      end

      it "<called_service> object must respond to #site." do
        invalid_service_class = Struct.new(:client_id, :client_secret)
        called_service        = invalid_service_class.new(valid_called_service_client_id, valid_called_service_client_secret)
        expect {Service::Connection.new(caller_service:       caller_service,
                                        called_service:       called_service,
                                        authorizator_service: authorizator_service)}.to raise_error
      end
    end

    context "- Interface" do
      context "#caller_service" do
        it "returns an object representing the caller service..." do
          expect(service_connection.caller_service).to eq(caller_service)
        end
      end

      context "#called_service" do
        it "returns an object representing the called service..." do
          expect(service_connection.called_service).to eq(called_service)
        end
      end

      context "#authorizator_service" do
        it "returns an object representing the Authorizator service..." do
          expect(service_connection.authorizator_service).to eq(authorizator_service)
        end
      end

      it "many more missing tests", pending:true do end

      # context "#talking_token: every pair of ideas4all services need a talking token to be able to communicate each other.
      #                         This token is returned by the Authorizator service only to its previously registered services." do
      #   context "   When called for the first time..." do
      #     before(:each) do
      #       authorizator_client.stub(:new_client_application).and_return(new_client_application)
      #       valid_access_token_data.stub(:get).and_return(valid_talking_token_data)
      #       valid_talking_token_data.stub(:parsed).and_return(valid_talking_token_data)
      #     end
#
      #     it "... a new oauth2 client instance to be able to reach the Authorizator service api is created and stored." do
      #       authorizator_client.talking_token
      #       client_application_cache = authorizator_client.instance_variable_get(:@client_application)
      #       expect(authorizator_client).to have_received(:new_client_application)
      #       expect(client_application_cache).not_to be_nil
      #     end
      #   end
      # end
    end
  end
end
