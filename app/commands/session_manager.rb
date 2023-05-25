module SessionManager
    def self.find_session(session_id)
        eval(REDIS_CLIENT.get("ussdsessions:#{session_id}"))
    rescue StandardError
        nil
    end

    def self.set_session(session_id, data)
        REDIS_CLIENT.setex("ussdsessions:#{session_id}", 10.minutes.to_i, data.to_s)
    rescue StandardError
        nil
    end

    def self.delete_session(session_id)
        REDIS_CLIENT.del("ussdsessions:#{session_id}")
    rescue StandardError
        nil
    end

    def self.set_mtn_date_month date
        REDIS_CLIENT.set("mtn_base_date", date.to_s)
    rescue StandardError
        nil
    end

    def self.set_orange_date_month date
        REDIS_CLIENT.set("orange_base_date", date.to_s)
    rescue StandardError
        nil
    end

    def self.get_mtn_date_month
        REDIS_CLIENT.get("mtn_base_date")
    rescue StandardError
        nil
    end

    def self.get_orange_date_month
        REDIS_CLIENT.get("orange_base_date")
    rescue StandardError
        nil
    end

    def self.set_mtn_counter counter 
        REDIS_CLIENT.set("mtn_counter", counter.to_s)
    rescue StandardError
        nil
    end

    def self.set_orange_counter counter 
        REDIS_CLIENT.set("orange_counter", counter.to_s)
    rescue StandardError
        nil
    end

    def self.get_mtn_counter
        REDIS_CLIENT.get("mtn_counter")
    rescue StandardError
        nil
    end

    def self.get_orange_counter
        REDIS_CLIENT.get("orange_counter")
    rescue StandardError
        nil
    end

    def self.contravention_types
        types = eval(REDIS_CLIENT.get('ussdsessions:contraventiontypes').to_s)
        return types if types.present?

        api = Mmgg::FetchRecords.call(params: {model_code: 'ContraventionType'})
        types = api['data']
        REDIS_CLIENT.setex('ussdsessions:contraventiontypes', 10.seconds.to_i, types.to_s)
        types
    rescue StandardError => e
        Rails.logger.debug(e.inspect)
        []
    end

    # Fetch Agents list
    def self.contravention_agents
        agents = eval(REDIS_CLIENT.get('ussdsessions:contraventionagents').to_s)

        return agents if agents.present?

        api = Mmgg::FetchRecords.call(params: {model_code: 'Agent'})
        agents = api['data']

        REDIS_CLIENT.setex('ussdsessions:contraventionagents', 60.seconds.to_i, agents.to_s)
        agents
    rescue StandardError => e  
        Rails.logger.debug(e.inspect)
        []
    end
    

    # Fetch contravention Notebook list
    def self.contravention_notebooks
        notebooks = eval(REDIS_CLIENT.get('ussdsessions:contraventionnotebooks').to_s)
        return notebooks if notebooks.present?

        api = Mmgg::FetchRecords.call(params: {model_code: 'ContraventionNotebook'})
        notebooks = api['data']

        REDIS_CLIENT.setex('ussdsessions:contraventionnotebooks', 60.seconds.to_i, notebooks.to_s)
        notebooks
    rescue => e 
        Rails.logger.debug(e.inspect)
        []
    end

    def self.fetch_contravention_types(classe_code)
        Mmgg::FetchContraventionTypes.call(params: {classe_code: classe_code})["data"]
    rescue => e 
        Rails.logger.debug(e.inspect)
        []
    end

    def self.fetch_contravention_type type
        Mmgg::FetchContraventionType.call(params: {type_code: type})["data"]
    rescue => e
        Rails.logger.debug e.inspect
        []
    end

    def self.fetch_transactions_filter(status, ticker_number)
        Mmgg::FetchTransactionFilter.call(params: {status: status, ticket_number: ticker_number})["data"]
    rescue => e
        Rails.logger.debug(e.inspect)
        []
    end

    def self.transactions
        transactions = eval(REDIS_CLIENT.get('ussdsessions:transactions').to_s)
        return transactions if transactions.present?
        transactions = Mmgg::FetchTransactions.call(params: {table_alias: "transactions_tickets"})["data"]
        REDIS_CLIENT.setex('ussdsessions:contraventionnotebooks', 10.seconds.to_i, transactions.to_s)
        transactions
    rescue => e
        Rails.logger.debug(e.inspect)
        []
    end
end