class MtnController < ApplicationController
  def index
    Rails.logger.debug("HEADERS: #{request.headers.first(50).to_h.keys}")
    session_id = params[:SessionId]
    msisdn = params[:MSISDN]

    Rails.logger.debug("SESSIONID: #{session_id}")
    Rails.logger.debug("MSISDN: #{msisdn}")
    Rails.logger.debug("QUERY_STRING: #{request.headers['QUERY_STRING']}")
    if session_id.blank?
      render plain: session_ended_page
    else

      new_request = params[:NewRequest].to_i 
      ussd_input = params[:input]

      Rails.logger.debug("USSD_STRING: #{ussd_input}")

      ussd_data = {
        session_id: session_id,
        msisdn: msisdn,
        ussd_input: ussd_input,
        new_request: new_request
      }
      
      ussd_result = Ussd::Mtn.display_menu(ussd_data)

      if ussd_result.status == 200
        data = ussd_result.data
        current_session = data[:ussd_session]
        view_text = data[:text] 
        # Freeflow tag, FC => flow continue, FB => flow break
        free_flow = 'FC'
        if current_session[:confirmation] == 'OK'
          payment_data = {}
          payment_data[:msisdn] = current_session[:msisdn]
          payment_data[:transaction_type] = current_session[:transaction_type]
          payment_data[:amount] = current_session[:save_amount].to_f
          payment_data[:currency] = 'GNF'
          payment_data[:wallet] = 'mtn_guinee'
          payment_data[:payload] = {

            description: 'USSD REDEVANCE INFORMATIQUE GUINEE CONAKRY',
            declarant_code: current_session[:save_code],
            ticket_number: current_session[:ticket_number]
          }

          Rails.logger.debug(payment_data)
          #payment_mtn = PaymentProcessor.call(params: payment_data)
          payment = Payment::Process.call(payment_data)
          response.set_header("charge", 'Y')
          response.set_header("amount", payment_data[:amount].to_i)
          response.set_header("cpRefId", current_session[:transaction_id])
          free_flow = 'FB'
          view_text = payment.response['status'] != 200 ?  payment_error : data[:text]
          SessionManager.delete_session(session_id)
        end
        response.set_header("Freeflow", free_flow)
        render plain: view_text
      else
        response.set_header("Freeflow", 'FB')
        render plain: error_page
      end   
  
    end
  
  end


  private
  
  def error_page
    "Service indisponible.\nVeuillez reessayer plus tard."
  end

  def session_ended_page
    'Desole, votre session a expire.'
  end

  def payment_error
    "Désolé, le paiement a échoué.\nVeuillez reéssayer plus tard."
  end
end
