require 'spec_helper'

describe 'The response of the Called service to a request to access its api, differs depending on the request,
          the attached talking_token, etc. These private methods return info about a received response:' do
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
  let(:service_connection)                 {Service::Connection.new(caller_service:       caller_service,
                                                                    called_service:       called_service,
                                                                    authorizator_service: authorizator_service)}
  let(:invalid_talking_token_error_codes)         {Service::Connection::Response::REMOTE_SERVICE_INVALID_TALKING_TOKEN_ERROR_CODES}
  let(:no_http_response)                          {double}
  let(:no_error_responding_response)              {double(:headers => {})}
  let(:error_blank_response)                      {double(:headers => {}, :error => nil)}
  let(:invalid_talking_token_error_code_response) {double(:headers => {}, :error => double(:code => invalid_talking_token_error_codes.first))}
  let(:no_invalid_talking_token_error_response)   {double(:headers => {}, :error => double(:code => 7), :headers => {})}

  context '#invalid_talking_token_response?(resp):' do
    it 'checks the response headers it the response object responds to #headers.' do
      Regexp.stub(:new).and_return(nil)
      service_connection.send(:invalid_talking_token_response?, no_http_response)
      expect(Regexp).not_to have_received(:new)
    end

    it 'returns false when the response do not respond to #error...' do
      expect(service_connection.send(:invalid_talking_token_response?, no_error_responding_response)).to be_false
    end

    it '...or the error object is present.' do
      expect(service_connection.send(:invalid_talking_token_response?, error_blank_response)).to be_false
    end

    it 'Returns the error code when the response.error.code is one of the invalid talking token ones...' do
      expect(invalid_talking_token_error_codes).to include(service_connection.send(:invalid_talking_token_response?, invalid_talking_token_error_code_response))
    end

    it 'In any other case, invalid_talking_token_response? should be false' do
      expect(service_connection.send(:invalid_talking_token_response?, no_invalid_talking_token_error_response)).to be_false
    end
  end


end
