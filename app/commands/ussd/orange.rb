require 'securerandom'
module Ussd
    module Orange 

        # Principal Menu
        def self.main_menu(session)
            Redevance::MainMenu.call session        
        end

        # Step 1
        def self.declarant_ticket_menu(session) 
            Redevance::CodeMenu.call session
        end

        # Step 2
        def self.amount_menu(session)
            Redevance::AmountMenu.call session
        end

        def self.recap_menu(session)
            %Q[<html>
                <body> Vous allez crediter #{session[:montant]} GNF pour le code declarant #{session[:save_code]}
                    <br />
                    <a href="orange/ussd/redevance?pageName=PAYMENT_PROCESS&option=1" key="1">. Confirmer</a>
                    <br />
                    <a href="orange/ussd/redevance?pageName=PAYMENT_PROCESS&option=2" key="2">. Annuler</a>
                </body>
            </html>]        
        end

        def self.confirmation_menu
            %Q[<html>
              <body>
                    <p> 
                        Veuillez patienter. Vous allez recevoir un message pour confirmer le paiement Mobile Money...
                    </p>     
              </body>
            </html>]
        end

       
        def self.menu_not_found
            %Q[<html>
              <body>
                    <p> 
                        menu indisponible...
                    </p>     
              </body>
            </html>]
        end       

        ### Message When payment failed
        def self.cancel_menu
            %Q[<html>
                <head>
                    <bearer>FINISH</bearer>
                </head>
                <body>
                    <p> 
                        L'opération a été annulée.
                    </p>     
                </body>
            </html>]
        end

        ## Quit the principal menu
        def self.quit_menu
            #Redevance::Quit.call session
            %Q[<html>
                <body><br/>Nous vous remercions, a tres bientot.
                </body>
            </html>]
        end

        # Création d'une nouvelle session utilisateur si elle n'existe pas et récupération de la session si elle existe
        def self.get_or_create_session(session_object)  
            # Recherche d'une session existante
            session_id = session_object[:session_id]
            ussd_session = SessionManager.find_session(session_id)

            return OpenStruct.new(status: 200, data: ussd_session) if ussd_session.present?

            if session_object[:pageName] == 'MAIN'
            session_record = Session.create_with(msisdn: session_object[:msisdn], status: 1, ussd_content: session_object[:ussd_input], started_at: Time.now).find_or_create_by(session_id: session_id)
            ussd_session = session_object.clone
            ussd_session[:msisdn] = session_object[:msisdn]
            ussd_session[:transaction_id] = session_record.ussd_trnx_id
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
            response  = {}
            return OpenStruct.new(status: 200, data: display_main_menu(ussd_session)) if content[:pageName] == 'main' 
            ussd_session[:ussd_input] = content[:ussd_input]
            session_id = content[:session_id]
            ussd_session[:pageName] = content[:pageName]
            ussd_session[:msisdn] = content[:msisdn]
            ussd_session[:code] = content[:code]
            ussd_session[:typeV] = content[:typeV]
            ussd_session[:montant] = content[:montant]
        
            case ussd_session[:pageName] #content[:pageName] #ussd_session[:cursor]
            # Pour un message de type begin, on affiche le menu principal
            when 'MAIN'
                # Menu principal
                response = display_main_menu(ussd_session)
            when 'INPUT_CODE_DCL_RI'
                response = display_declarant_code_menu(ussd_session)
            when 'INPUT_CODE_DECLARANT'
                response = display_amount_menu(ussd_session)
            when 'INPUT_AMOUNT'
                response = display_recap_menu(ussd_session)
            when 'PAYMENT_PROCESS'
                response = display_momo_password_menu(ussd_session)
            end
            
            

            if response[:status] == 1
                new_session = response[:ussd_session]
                SessionManager.set_session(session_id, new_session)
            else
                SessionManager.delete_session(session_id)
                session_record = UssdSession.find_by(session_id: session_id)
                session_record.update(ended_at: Time.now)
            end
            OpenStruct.new(status: 200, data: response)
        end


        # Menu - menu principal
        def self.display_main_menu(ussd_session)
            new_session = ussd_session.clone
            new_session[:confirmation] = 'NOK'
            text = main_menu(new_session)
            {ussd_session: new_session, text: text, status: 1}
        end

        # Menu - Selon le choix de l'utilisateur sur le menu principal
        def self.display_declarant_code_menu(ussd_session)
            new_session = ussd_session.clone
            input = new_session[:ussd_input].to_i
            new_session[:transaction_type] = 'redevance_ticket'
            text = ''
            if input == 1
                text = declarant_ticket_menu(new_session)
            elsif input == 2
                text = menu_not_found
            else
                text = quit_menu
            end
            
            {ussd_session: new_session, text: text, status: 1}
        end

        def self.display_amount_menu(ussd_session)
            new_session = ussd_session.clone
            code = ussd_session[:code].to_s
            new_session[:save_code] = code
            text = amount_menu(new_session).strip
            {ussd_session: new_session, text: text, status: 1}
        end

        def self.display_recap_menu(ussd_session)
            new_session = ussd_session.clone
            montant = new_session[:montant]
            new_session[:save_amount] = montant
            text = recap_menu(new_session)
            {ussd_session: new_session, text: text, status: 1}
        end


        def self.display_momo_password_menu(ussd_session)
            new_session = ussd_session.clone
            confirmation = new_session[:ussd_input].to_i
            text = ''
            if confirmation == 1
                new_session[:confirmation] =  'OK'
                new_session[:ticket_number] = "RDG" + SecureRandom.hex(2).upcase
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