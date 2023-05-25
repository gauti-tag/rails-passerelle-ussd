require 'net/http'
module Redevance
    class CodeMenu < ApplicationService
        URI_CODE_PAGE = "/ws_ri/ussd/getPage"
        URI_VERIFY_CODE = "/ws_ri/ussd/checkCodeDeclarant"
        attr_reader :params
        # Initialize all coming params 
        def initialize(params)
            @params = params
        end

        def call 
            url = "#{ENV['redevance_guinee_url']}#{URI_CODE_PAGE}?pageName=#{params[:pageName]}&msisdn=#{params[:msisdn]}&token=#{ENV['redevance_guinee_token']}"
            end_url = URI(url)
            Rails.logger.debug("REDEVANCE GUINEE DECLARANT CODE PAGE URL REQUEST SENT : \n #{end_url}")
            response = Net::HTTP.get(end_url).strip
            response = response.gsub("#{ENV['redevance_guinee_url']}#{URI_VERIFY_CODE}",'/orange/ussd/redevance')
            response
        end
    end
end