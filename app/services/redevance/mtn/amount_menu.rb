require 'net/http'
module Redevance
    module Mtn
        class AmountMenu < ApplicationService
            URI_CODE_PAGE = "/ws_ri/ussd/checkCodeDeclarantMtn"
            attr_reader :params
            # Initialize all coming params 
            def initialize(params)
                @params = params
            end

            def call 
                url = "#{ENV['redevance_guinee_url']}#{URI_CODE_PAGE}?code=#{params[:code]}&typeV=#{params[:typeV]}&msisdn=#{params[:msisdn]}&token=#{ENV['redevance_guinee_token']}"
                end_url = URI(url)
                Rails.logger.debug("REDEVANCE CODE DECLARANT REQUEST SENT : \n #{end_url}")
                Net::HTTP.get_response(end_url)
            end
        end
    end
end