require 'net/http'
module Redevance
    module Mtn
        class CodeMenu < ApplicationService
            URI_CODE_PAGE = "/ws_ri/ussd/getPage"
            attr_reader :params
            # Initialize all coming params 
            def initialize(params)
                @params = params
            end

            def call 
                url = "#{ENV['redevance_guinee_url']}#{URI_CODE_PAGE}?pageName=#{params[:pageName]}&msisdn=#{params[:msisdn]}&token=#{ENV['redevance_guinee_token']}"
                end_url = URI(url)
                Rails.logger.debug("REDEVANCE GUINEE DECLARANT CODE MTN PAGE URL REQUEST SENT : \n #{end_url}")
                response = Net::HTTP.get(end_url).strip
                response
            end
        end
    end
end