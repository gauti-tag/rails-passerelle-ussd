module Ussd 
    module Mtn 
        # Principal Menu
        def self.main_menu session
            Redevance::Mtn::MainMenu.call session
        end

         # Step 1
        def self.declarant_ticket_menu session
            Redevance::Mtn::CodeMenu.call session
        end

        def self.check_declarent_ticket session
          Redevance::Mtn::AmountMenu.call session
        end
        
        # Recap infos 
        def self.recap_menu session
            "Vous allez crediter #{session[:montant]} GNF pour le code declarant #{session[:save_code]}\n1. Confirmer\n2. Annuler"        
        end


        def self.confirmation_menu
            "Veuillez patienter. Vous allez recevoir un message pour confirmer le paiement Mobile Money..."
        end

        def self.menu_not_found
            "menu indisponible..."
        end
        
         ### Message When payment failed
        def self.cancel_menu
            "L'opération a été annulée."
        end

        ## Quit the principal menu
        def self.quit_menu
            "Nous vous remercions, a tres bientot."
        end
    
          # Création d'une nouvelle session utilisateur si elle n'existe pas ou récupération de la session si elle existe
        def self.get_or_create_session(session_object)
            # Recherche d'une session existante
            session_id = session_object[:session_id]
            ussd_session = SessionManager.find_session(session_id)
        
            return OpenStruct.new(status: 200, data: ussd_session) if ussd_session.present?
        
            if session_object[:new_request] == 1
              session_record = Session.create_with(msisdn: session_object[:msisdn], status: 1, ussd_content: session_object[:ussd_input], started_at: Time.now).find_or_create_by(session_id: session_id)
              ussd_session = session_object.clone
              ussd_session[:msisdn] = session_object[:msisdn]
              ussd_session[:transaction_id] = session_record.ussd_trnx_id
              ussd_session[:confirmation] = ''
              ussd_session[:cursor] = 0
              SessionManager.set_session(session_id, ussd_session)
              return OpenStruct.new(status: 200, data: ussd_session)
            else
              session_record = Session.find_or_create_by(session_id: session_id)
              session_record.update(msisdn: session_object[:msisdn], status: 2, ussd_content: session_object[:ussd_input], ended_at: Time.now)
              SessionManager.delete_session(session_id)
              return OpenStruct.new(status: 400, message: 'Session end.')
            end
        end
        
          # Affichage du menu à l'utilisateur en fonction de son parcours client
        def self.display_menu(content)
            # Création d'un hash de session
            session_data = get_or_create_session(content)
            return session_data if session_data.status != 200
            
            ussd_session = session_data.data
            ussd_session.symbolize_keys!
          
            ussd_session[:ussd_input] = content[:ussd_input]
            ussd_session[:msisdn] = content[:msisdn]
            session_id = content[:session_id]
            response  = {}
            cursor = ussd_session[:cursor].to_i
        
            if content[:new_request] == 1
                response = display_main_menu(ussd_session)
            else
              # Menu suivant selon le curseur
                case cursor
                when 0
                    # Menu saisie inviter à sersir le code declarant
                    response = display_declarant_code_menu(ussd_session) 
                when 1
                    # Logique vérification du code declarant - Menu input montant  
                    response = display_amount_menu(ussd_session)
                when 2
                    # Menu Recap Infos 
                    response = display_recap_menu(ussd_session)
                when 3
                    # Final Message 
                    response = display_momo_password_menu(ussd_session)
                end
  
            end
        
            
        
            if response[:status] == 1
              new_session = response[:ussd_session]
              SessionManager.set_session(session_id, new_session)
            else
              SessionManager.delete_session(session_id)
              session_record = Session.find_by(session_id: session_id)
              session_record.update(ended_at: Time.now)
            end

          OpenStruct.new(status: 200, data: response)
        end
        
        
        # Menu - menu principal
        def self.display_main_menu(ussd_session)
          new_session = ussd_session.clone
          new_session[:cursor] = 0
          new_session[:confirmation] = 'NOK'
          new_session[:ussd_input] = ''
          new_session[:pageName] = 'MAIN_MTN'
          text = main_menu(new_session)
          {ussd_session: new_session, text: text, status: 1}
        end

        ###
        # Etape 2: Display input do payment RI
        ###
        def self.display_declarant_code_menu(ussd_session)
          new_session = ussd_session.clone
          input = new_session[:ussd_input].to_i
          new_session[:transaction_type] = 'redevance_ticket'
          text = ''
          if input == 1
              new_session[:cursor] = 1
              new_session[:pageName] = 'INPUT_CODE_DECL_RI_MTN'
              text = declarant_ticket_menu(new_session)
          elsif input == 2
              text = menu_not_found
              new_session[:cursor] = 0
          else
              text = quit_menu
              new_session[:cursor] = 0
          end
          
          {ussd_session: new_session, text: text, status: 1}
        end
        
        ###
        # Etape 2: Display input code declarant
        ###
          
        def self.display_amount_menu(ussd_session)
          new_session = ussd_session.clone
          code = new_session[:ussd_input].to_s
          new_session[:code] = code 
          new_session[:save_code] = code
          new_session[:typeV] = "RI" 
          text = ''
          resp = check_declarent_ticket(new_session)
          if resp.code.to_i == 200
            new_session[:cursor] = 2
            text = resp.body
          else
            text = resp.body 
            new_session[:cursor] = 1
          end
          {ussd_session: new_session, text: text, status: 1}
        end
        
        ###
        # Etape 3: Display menu input amount and recap infos and handle payment choice
        ###
        def self.display_recap_menu(ussd_session)
          new_session = ussd_session.clone
          montant = new_session[:ussd_input]
          new_session[:montant] = montant
          new_session[:save_amount] = montant
          text = recap_menu(new_session)
          new_session[:cursor] = 3
          {ussd_session: new_session, text: text, status: 1}
        end

        ###
        # Etape Finale: Send Payment Request or rejected 
        ###
        def self.display_momo_password_menu(ussd_session)
          new_session = ussd_session.clone
          confirmation = new_session[:ussd_input].to_i
          text = ''
          if confirmation == 1
              new_session[:confirmation] =  'OK'
              new_session[:ticket_number] = "RDM" + SecureRandom.hex(2).upcase
              text = confirmation_menu
          else
              confirmation = 1
              new_session[:confirmation] = 'NOK'
              text = cancel_menu
          end
          
          {ussd_session: new_session, text: text, status: confirmation}
        end
    end
end