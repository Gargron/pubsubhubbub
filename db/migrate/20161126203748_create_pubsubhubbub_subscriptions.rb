class CreatePubsubhubbubSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :pubsubhubbub_subscriptions do |t|
      t.string :topic, null: false, default: ''
      t.string :callback, null: false, default: ''
      t.string :mode, null: false, default: ''
      t.string :challenge, null: false, default: ''
      t.string :secret, null: true, default: nil
      t.boolean :confirmed, null: false, default: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :pubsubhubbub_subscriptions, [:topic, :callback], unique: true
  end
end
