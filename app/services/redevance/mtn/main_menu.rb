# Arthor : Gautier Tiehoule
require 'net/http'
module Redevance
    module Mtn
        class MainMenu < ApplicationService
            URI_MAIN_PAGE = "/ws_ri/ussd/getPage"
            attr_reader :params
            # Initialize all coming params 
            def initialize(params)
                @params = params
            end

            def call 
                url = "#{ENV['redevance_guinee_url']}#{URI_MAIN_PAGE}?pageName=#{params[:pageName]}&msisdn=#{params[:msisdn]}&token=#{ENV['redevance_guinee_token']}"
                end_url = URI(url)
                Rails.logger.debug("REDEVANCE GUINEE MTN MAIN PAGE URL REQUEST SENT : \n #{end_url}")
                response = Net::HTTP.get(end_url).strip
                response
            end

        end
    end
end