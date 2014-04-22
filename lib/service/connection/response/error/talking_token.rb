require 'service/connection/response/error/base'

module Service
  class Connection
    module Response
      module Error


        # The exception to raise when an invalid talking token is received from the Authorizator service.
        class TalkingToken < Base

          def initialize(msg: "Got invalid talking token", data:)
            super
          end

        end


      end
    end
  end
end
