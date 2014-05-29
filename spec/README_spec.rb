require 'README_FOR_USERS_spec'
require 'connection_spec'


describe "The service-connection gem is the messenger among ideas4all services. It:
              - allows the caller service to access the called service's endpoints.
              - transport protocol is transparent for the caller.
              - the communication is secured via Oauth2 protocol and ideas4all authorized talking-token mechanism" do

    include_context 'as a user:'
    include_context 'connection:'
end
