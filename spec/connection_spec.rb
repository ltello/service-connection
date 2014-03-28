require 'spec_helper'

describe "The service-connection gem is the messenger among ideas4all services. It:
              - allows the caller service to access the called service's endpoints.
              - transport protocol is transparent for the caller.
              - the communication is secured via Oauth2 protocol and ideas4all authorized talking-token mechanism." do

  context "Service::Connection: this class access target endpoints carrying params." do
    let(:valid_caller_service_client_id)     {'12345'}
    let(:valid_caller_service_client_secret) {'67890'}
    let(:valid_caller_service_site)          {'https://caller_service.ideas4all.com'}
    let(:valid_caller_service_credentials)   {{:client_id     => valid_caller_service_client_id,
                                               :client_secret => valid_caller_service_client_secret}}
    let(:valid_caller_service_data)          {valid_caller_service_credentials.merge(:site => valid_caller_service_site)}

    let(:valid_called_service_client_id)     {'3458686675'}
    let(:valid_called_service_client_secret) {'671237685234890'}
    let(:valid_called_service_site)          {'https://called_service.ideas4all.com'}
    let(:valid_called_service_credentials)   {{:client_id     => valid_called_service_client_id,
                                               :client_secret => valid_called_service_client_secret}}
    let(:valid_called_service_data)          {valid_called_service_credentials.merge(:site => valid_called_service_site)}

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

    let(:service_connection)          {Service::Connection.new(:caller_service_data => valid_caller_service_data,
                                                               :called_service_data => valid_called_service_data)}
    context "- Instantiation:" do
      it "To create an Service::Connection instance you must provide at least two option params: :caller_service_data and :called_service_data." do
        expect(service_connection).to be_a(Service::Connection)
      end

      it "An error will be raised otherwise." do
        expect{Service::Connection.new}.to raise_error
        expect{Service::Connection.new(:caller_service_data => {})}.to raise_error
        expect{Service::Connection.new(:called_service_data => {:client_id => '9797'})}.to raise_error
      end

      it ":caller_service_data hash must include :client_id key-value pair..." do
        expect {Service::Connection.new(:caller_service_data => {:client_secret => 'ljasj'},
                                        :called_service_data => {:client_id     => '973247234',
                                                                 :client_secret => '2309823948',
                                                                 :site          => 'site'})}.to raise_error
      end

      it "...as well as :client_secret key-value pair." do
        expect {Service::Connection.new(:caller_service_data => {:client_id     => '098397234'},
                                        :called_service_data => {:client_id     => '973247234',
                                                                 :client_secret => '2309823948',
                                                                 :site          => 'site'})}.to raise_error
      end

      it ":called_service_data hash must include at least :site key-value pair." do
        expect {Service::Connection.new(:caller_service_data => {:client_id     => '098397234',
                                                                 :client_secret => '324hgfh948'},
                                        :called_service_data => {:client_id     => '973247234',
                                                                 :client_secret => '2309823948'})}.to raise_error
      end
    end

    context "- Interface" do
      context "#caller_service" do
        it "returns a hash with properties corresponding to the caller service..." do
          expect(service_connection.caller_service).to eq(valid_caller_service_data)
        end
        it "...including at least :client_id and :client_secret" do
          expect(service_connection.caller_service).to have_key(:client_id)
          expect(service_connection.caller_service).to have_key(:client_secret)
        end
      end

      context "#called_service" do
        it "returns a hash with properties corresponding to the called service..." do
          expect(service_connection.called_service).to eq(valid_called_service_data)
        end
        it "...including at least :site" do
          expect(service_connection.caller_service).to have_key(:site)
        end
      end

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
