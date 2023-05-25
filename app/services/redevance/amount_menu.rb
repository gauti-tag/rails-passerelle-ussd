require 'net/http'
module Redevance
    class AmountMenu < ApplicationService
        URI_CODE_PAGE = "/ws_ri/ussd/checkCodeDeclarant"
        URI_VERIFY_CODE = "/ws_ri/ussd/payerRI"
        attr_reader :params
        # Initialize all coming params 
        def initialize(params)
            @params = params
        end

        def call 
            url = "#{ENV['redevance_guinee_url']}#{URI_CODE_PAGE}?code=#{params[:code]}&typeV=#{params[:typeV]}&msisdn=#{params[:msisdn]}&token=#{ENV['redevance_guinee_token']}"
            end_url = URI(url)
            Rails.logger.debug("REDEVANCE GUINEE AMOUNT PAGE URL REQUEST SENT : \n #{end_url}")
            response = Net::HTTP.get(end_url).strip
            response = response.include?("#{ENV['redevance_guinee_url']}#{URI_VERIFY_CODE}") ? response.gsub("#{ENV['redevance_guinee_url']}#{URI_VERIFY_CODE}",'/orange/ussd/redevance') : response
            response = response.include?("#{ENV['redevance_guinee_url']}#{URI_CODE_PAGE}") ? response.gsub("#{ENV['redevance_guinee_url']}#{URI_CODE_PAGE}",'/orange/ussd/redevance') : response
        end
    end
end