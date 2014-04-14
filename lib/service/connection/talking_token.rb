require "oauth2"

module Service
  class Connection

    # A class to create talking token instances. Inherits behaviour from Oauth2::AccessToken.
    class TalkingToken < ::OAuth2::AccessToken

      def scopes
        params['scopes']
      end
    end

  end
end
