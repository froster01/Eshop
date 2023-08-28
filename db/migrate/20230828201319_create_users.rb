class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :profile_information
      t.string :verification_token
      t.boolean :verified, default: 0
      t.datetime :verification_token_expires_at
      t.string :reset_token
      t.datetime :reset_token_expires_at
      t.datetime :reset_token_used_at

      t.timestamps
    end
  end
end
