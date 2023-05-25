class Session < ApplicationRecord
    validates :msisdn, presence: true
    validates :session_id, presence: true, uniqueness: true

    enum status: [:pending, :active, :suspended]

    before_create :set_transaction_id

    def set_transaction_id
    return if ussd_trnx_id.present?
    self.ussd_trnx_id = SecureRandom.hex(13)
    end
end
