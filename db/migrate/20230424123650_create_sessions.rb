class CreateSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :sessions do |t|
      t.string :session_id
      t.string :ussd_trnx_id
      t.string :msisdn
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :status, default: 1
      t.string :ussd_content
      
      t.timestamps
    end
    add_index :sessions, :session_id, unique: true
  end
end
