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
    let(:valid_talking_token_value)   {'1234567890123456789012345678901234567890'}
    let(:talking_token_type)          {'bearer'}
    let(:talking_token_expires_in)    {1000}
    let(:talking_token_scope)         {'service_mate'}
    let(:valid_talking_token_data)    {{'access_token' => valid_talking_token_value,
                                        'token_type'   => talking_token_type,
                                        'expires_in'   => talking_token_expires_in,
                                        'scope'        => talking_token_scope}}
    let(:new_client_application)      {double(:request => double(:parsed => nil))}
    let(:talking_token)               {Service::Connection::TalkingToken.new(caller_service:caller_service, called_service:called_service, authorizator_service:authorizator_service)}
    let(:service_connection) {Service::Connection.new(caller_service:       caller_service,
                                                      called_service:       called_service,
                                                      authorizator_service: authorizator_service)}

    context "- Instantiation:" do

      shared_examples "an error unless" do |title|
        it title do
          expect {Service::Connection.new(caller_service:       caller_service,
                                          called_service:       called_service,
                                          authorizator_service: authorizator_service)}.to raise_error
        end
      end

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

      alias_it_behaves_like_to :also_raise, "also, raise"

      also_raise "an error unless", "<caller_service> object responds to #client_id..."  do
        let(:invalid_service_class) {Struct.new(:client_secret, :site)}
        let(:caller_service)        {invalid_service_class.new(valid_caller_service_client_secret, valid_caller_service_site)}
      end

      also_raise "an error unless", "<caller_service> object responds to :client_secret." do
        let(:invalid_service_class) {Struct.new(:client_id, :site)}
        let(:caller_service)        {invalid_service_class.new(valid_caller_service_client_id, valid_caller_service_site)}
      end

      also_raise "an error unless", "<called_service> object responds to #site." do
        let(:invalid_service_class) {Struct.new(:client_id, :client_secret)}
        let(:called_service)        {invalid_service_class.new(valid_called_service_client_id, valid_called_service_client_secret)}
      end

      also_raise "an error unless", "<authorizator_service> object responds to #site." do
        let(:invalid_service_class) {Struct.new(:client_id, :client_secret)}
        let(:authorizator_service)  {invalid_service_class.new(nil, nil)}
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

      context "The following methods are provided to make requests to the called service endpoints.
               To do that, the processing is forwarded to an OAuth2::Client instance.
               See its documentation for a list of opts allowed (:params, :body...) and the use of the &block:" do
        before(:each) do
          authorizator_client.stub(:talking_token).and_return(valid_talking_token_data)
          Authorizator::Client.stub(:new).and_return(authorizator_client)
          OAuth2::Client.stub(:new).and_return(new_client_application)
          service_connection.stub(:talking_token).and_return(talking_token)
        end

        it "#headers:
            returns the Authorization header to be sent in every request to the Called service." do
            expect(service_connection.headers).to eq({"Authorization" => "Bearer #{valid_talking_token_value}"})
        end

        it "#get(endpoint_relative_path, opts={}, &block):
            makes a <get> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            service_connection.get('/path_to_called_service_endpoint', params: {id:7})
            expect(new_client_application).to have_received(:request).with(:get, '/path_to_called_service_endpoint', {params: {id:7}}.merge!(headers: service_connection.headers)).once
        end

        it "#post(endpoint_relative_path, opts={}, &block):
            makes a <post> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            service_connection.post('/path_to_called_service_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:post, '/path_to_called_service_endpoint', {body: {id:7}}.merge!(headers: service_connection.headers)).once
        end

        it "#put(endpoint_relative_path, opts={}, &block):
            makes a <put> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            service_connection.put('/path_to_called_service_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:put, '/path_to_called_service_endpoint', {body: {id:7}}.merge!(headers: service_connection.headers)).once
        end

        it "#patch(endpoint_relative_path, opts={}, &block):
            makes a <patch> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            service_connection.patch('/path_to_called_service_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:patch, '/path_to_called_service_endpoint', {body: {id:7}}.merge!(headers: service_connection.headers)).once
        end

        it "#delete(endpoint_relative_path, opts={}, &block):
            makes a <delete> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            service_connection.delete('/path_to_called_service_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:delete, '/path_to_called_service_endpoint', {body: {id:7}}.merge!(headers: service_connection.headers)).once
        end
      end

    end
  end
end
