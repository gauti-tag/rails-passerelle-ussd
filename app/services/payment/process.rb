require 'typhoeus'
module Payment 
    class Process < ApplicationService

        def initialize(params)
            @params = params
        end

        attr_reader :params

        def call
            body = {request: params}
            request = Typhoeus::Request.new(
                "#{ENV['CORE_URL']}/api/ussd/payment",
                method: :post,
                body: body.to_json ,
                headers: { 'Content-Type': 'application/json', 'Authorization' => "Bearer #{auth_token}" }
            )
            request.run
            response = JSON.parse(request.response.body)

            OpenStruct.new(status: 200, response: response)
        end
         
        private

        def auth_token
            token = REDIS_CLIENT.get('core:auth_token')
            return token if token.present?
        
            request = Typhoeus::Request.new(auth_endpoint, method: :post, body: auth_params.to_json, headers: { 'Content-Type': 'application/json' })
            request.run
            response = request.response
            if response.code == 200
              token = JSON.parse(response.body)['token']
              REDIS_CLIENT.setex('core:auth_token', 1.hour.to_i, token)
            end
            token
        end
        
        def auth_endpoint    
            "#{ENV['CORE_URL']}/platform/auth"
        end
      
        def auth_params
        {
            auth: {
                api_key: ENV['CORE_API_KEY'],
                api_secret: ENV['CORE_API_SECRET']
            }
        }
        end
    end
end