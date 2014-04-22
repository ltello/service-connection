require 'spec_helper'

describe "An talking token is an object whose value must be included in the Authorization header of any request
          to an ideas4all service for it to give access to its protected resources (api) to external caller services." do

  context "Service::Connection::TalkingToken: is the class representing obtained talking tokens from the
           Authorizator Service:" do
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
    let(:talking_token_expires_in)    {'1000'}
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
          expect {Service::Connection::TalkingToken.new(caller_service:       caller_service,
                                                        called_service:       called_service,
                                                        authorizator_service: authorizator_service)}.to raise_error
        end
      end

      context 'params presence:' do
        before(:each) do
          authorizator_client.stub(:talking_token).and_return(valid_talking_token_data)
          Authorizator::Client.stub(:new).and_return(authorizator_client)
          OAuth2::Client.stub(:new).and_return(new_client_application)
          # service_connection.stub(:talking_token).and_return(talking_token)
        end

        it "To create a Service::Connection instance you must provide three objects: :caller_service and :called_service and :authorizator_service." do
          expect(talking_token).to be_a(Service::Connection::TalkingToken)
        end

        it "An error will be raised otherwise." do
          expect{Service::Connection::TalkingToken.new}.to raise_error
          expect{Service::Connection::TalkingToken.new(caller_service: caller_service)}.to raise_error(ArgumentError)
          expect{Service::Connection::TalkingToken.new(called_service: called_service)}.to raise_error(ArgumentError)
          expect{Service::Connection::TalkingToken.new(caller_service: caller_service, called_service: called_service)}.to raise_error(ArgumentError)
          expect{Service::Connection::TalkingToken.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error(ArgumentError)
          expect{Service::Connection::TalkingToken.new(called_service: called_service, authorizator_service: authorizator_service)}.to raise_error(ArgumentError)
        end
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

      context "at instantitation time, a new talking token data from Authorizator service is obtained, so:" do
        let(:no_talking_token_data)                {nil}
        let(:empty_talking_token_data)             {{}}
        let(:no_hash_talking_token_data)           {"ajldkasfj"}
        let(:no_token_value_talking_token_data)    {{'expires_in' => '25', 'scope' => 'service_mate', 'token_type' => 'bearer'}}
        let(:empty_token_value_talking_token_data) {{'expires_in' => '25', 'scope' => 'service_mate', 'token_type' => 'bearer', 'access_token' => ''}}
        let(:invalid_scope_talking_token_data)     {{'expires_in' => '25', 'scope' => 'magic',        'token_type' => 'bearer', 'access_token' => ''}}

        before(:each) do
          authorizator_client.stub(:talking_token).and_return(valid_talking_token_data)
          Authorizator::Client.stub(:new).and_return(authorizator_client)
          OAuth2::Client.stub(:new).and_return(new_client_application)
          # service_connection.stub(:talking_token).and_return(talking_token)
        end

        shared_examples "a talking token error if" do |title|
          it title do
            expect {Service::Connection::TalkingToken.new(caller_service:       caller_service,
                                                          called_service:       called_service,
                                                          authorizator_service: authorizator_service)}.to raise_error(Service::Connection::Response::Error::TalkingToken)
          end
        end

        also_raise "a talking token error if", "no remote talking token can be obtained from the Authorizator service." do
          before {authorizator_client.stub(:talking_token).and_return(no_talking_token_data)}
        end

        also_raise "a talking token error if", "a void remote talking token is received." do
          before {authorizator_client.stub(:talking_token).and_return(empty_talking_token_data)}
        end

        also_raise "a talking token error if", "a no Hash remote talking token is received." do
          before {authorizator_client.stub(:talking_token).and_return(no_hash_talking_token_data)}
        end

        also_raise "a talking token error if", "a remote talking token with no token string is received." do
          before {authorizator_client.stub(:talking_token).and_return(no_token_value_talking_token_data)}
        end

        also_raise "a talking token error if", "a remote talking token with empty token string is received." do
          before {authorizator_client.stub(:talking_token).and_return(empty_token_value_talking_token_data)}
        end

        also_raise "a talking token error if", "a remote talking token with invalid scope is received." do
          before {authorizator_client.stub(:talking_token).and_return(invalid_scope_talking_token_data)}
        end
      end

    end

    context "- Interface" do
      before(:each) do
        authorizator_client.stub(:talking_token).and_return(valid_talking_token_data)
        Authorizator::Client.stub(:new).and_return(authorizator_client)
        OAuth2::Client.stub(:new).and_return(new_client_application)
        # service_connection.stub(:talking_token).and_return(talking_token)
        # OAuth2::Client.stub(:new).and_return(new_client_application)
      end

      context "#caller_service" do
        it "returns an object representing the service accessing the Authorizator" do
          expect(talking_token.caller_service).to eq(caller_service)
        end
      end

      context "#called_service" do
        it "returns an object representing the service where to address api requests" do
          expect(talking_token.called_service).to eq(called_service)
        end
      end

      context "#authorizator_service" do
        it "returns an object representing the Authorizator service" do
          expect(talking_token.authorizator_service).to eq(authorizator_service)
        end
      end

      context "The following methods are provided to make requests to the Called service endpoints.
               To do that, the processing is forwarded to an OAuth2::Client instance.
               See its documentation for a list of opts allowed (:params, :body...) and the use of the &block:" do

        it "#headers:
            returns the Authorization header to be sent in every request to the Called service." do
            expect(talking_token.headers).to eq({"Authorization" => "Bearer #{valid_talking_token_value}"})
        end

        it "#get(endpoint_relative_path, opts={}, &block):
            makes a <get> request to the called service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            talking_token.get('/path_to_endpoint', params: {id:7})
            expect(new_client_application).to have_received(:request).with(:get, '/path_to_endpoint', {params: {id:7}}.merge!(headers: talking_token.headers)).once
        end

        it "#post(endpoint_relative_path, opts={}, &block):
            makes a <post> request to the called service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            talking_token.post('/path_to_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:post, '/path_to_endpoint', {body: {id:7}}.merge!(headers: talking_token.headers)).once
        end

        it "#put(endpoint_relative_path, opts={}, &block):
            makes a <put> request to the called service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            talking_token.put('/path_to_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:put, '/path_to_endpoint', {body: {id:7}}.merge!(headers: talking_token.headers)).once
        end

        it "#patch(endpoint_relative_path, opts={}, &block):
            makes a <patch> request to the called service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            talking_token.patch('/path_to_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:patch, '/path_to_endpoint', {body: {id:7}}.merge!(headers: talking_token.headers)).once
        end

        it "#delete(endpoint_relative_path, opts={}, &block):
            makes a <delete> request to the called service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the talking token's token value" do
            talking_token.delete('/path_to_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:delete, '/path_to_endpoint', {body: {id:7}}.merge!(headers: talking_token.headers)).once
        end
      end

    end
  end
end
