# Arthor : Gautier Tiehoule
require 'net/http'
module Redevance
    class Quit < ApplicationService
        QUIT_URI = "/ws_ri/ussd/getPage"
        attr_reader :params
        # Initialize all coming params 
        def initialize(params)
            @params = params
        end

        def call 
            url = "#{ENV['redevance_guinee_url']}#{QUIT_URI}?pageName=QUITER&msisdn=#{params[:msisdn]}&token=#{ENV['redevance_guinee_token']}"
            end_url = URI(url)
            Rails.logger.debug("REDEVANCE GUINEE PAGE QUIT URL REQUEST SENT : \n #{end_url}")
            response = Net::HTTP.get(end_url).strip
            response = response.gsub("#{ENV['redevance_guinee_url']}#{QUIT_URI}",'/orange/ussd/redevance')
            response
        end

    end
end