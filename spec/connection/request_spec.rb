require 'spec_helper'

describe 'Requests to the Called service endpoints are made via a Service::Connection::TalkingToken instance
          stored, accessed and renewed calling #talking_token method and #maybe_renewing_talking_token wrapper.' do
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

  before(:each) do
    authorizator_client.stub(:talking_token).and_return(valid_talking_token_data)
    Authorizator::Client.stub(:new).and_return(authorizator_client)
    OAuth2::Client.stub(:new).and_return(new_client_application)
    service_connection.stub(:talking_token).and_return(talking_token)
  end

  context '#talking_token:' do
    it 'Before calling it for the first time, the store is empty.' do
      expect(authorizator_client.instance_variable_get(:@talking_token)).to be_nil
    end

    context 'Calls to #talking_token:' do
      let!(:first_authorizator_talking_token_to_use)  {service_connection.send(:talking_token)}

      it 'In the first call to #talking_token method, a new Service::Connection::TalkingToken is returned and
          stored to be used in subsequent calls.' do
        expect(service_connection.send(:talking_token)).not_to be_nil
      end

      it 'The next calls return the previously stored talking token.' do
        expect{service_connection.send(:talking_token)}.not_to change {service_connection.instance_variable_get(:@talking_token)}
        expect{service_connection.send(:talking_token)}.not_to change {service_connection.instance_variable_get(:@talking_token)}
        expect(service_connection.send(:talking_token)).to eq(service_connection.send(:talking_token))
      end
    end
  end


  context '#maybe_renewing_talking_token:
           Every request to the Called service endpoints (like talking_token.get(any_endpoint,...)) should be wrapped in
           a call to #maybe_renewing_talking_token to repeat the request in case the talking_token used is not valid anymore
           (revoked, expired, invalid, ..., missing) and need to be automatically renewed (requested again to the Authorizator
           service).' do
    let(:valid_return_data)          {double(:headers => {}, :[] => 'yes')}
    let(:no_http_response_data)      {double}
    let(:invalid_talking_token_data) {double(:error => double(:code => Service::Connection::Response::REMOTE_SERVICE_INVALID_TALKING_TOKEN_ERROR_CODES.first), :headers => {})}

    context 'if the block given to #maybe_renewing_talking_token do not return an http response object (object responding to #header => Hash instance)...' do
      it "...the response cannot be declared to be invalid because of its heades and repeat the request renewing the talking token" do
        service_connection.send(:talking_token).stub(:get).with('/endpoint').and_return(no_http_response_data)
        block = Proc.new {service_connection.send(:talking_token).get('/endpoint')}
        service_connection.send(:maybe_renewing_talking_token, &block)
        expect(service_connection.send(:talking_token)).to have_received(:get).once
      end
    end

    it '#maybe_renewing_talking_token executes the given block once...' do
      service_connection.send(:talking_token).stub(:get).with('/endpoint').and_return(valid_return_data)
      block = Proc.new {service_connection.send(:talking_token).get('/endpoint')}
      service_connection.send(:maybe_renewing_talking_token, &block)
      expect(service_connection.send(:talking_token)).to have_received(:get).once
    end

    it '...unless the talking token is invalid so it is called twice.' do
      calls_to_block = 0
      block = Proc.new do
        calls_to_block += 1
        service_connection.send(:talking_token).stub(:get).with('/endpoint').and_return(invalid_talking_token_data)
        service_connection.send(:talking_token).get('/endpoint')
      end
      expect {service_connection.send(:maybe_renewing_talking_token, &block)}.to raise_error
      expect(calls_to_block).to eq(2)
    end

  end
end

