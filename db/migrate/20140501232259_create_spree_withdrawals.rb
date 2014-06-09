class CreateSpreeWithdrawals < ActiveRecord::Migration
  def change
    create_table :spree_withdrawals do |t|
      t.references :user, :order
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.string :description
      t.integer :category
      t.datetime :transferred_at
      
      t.timestamps
    end
  end
end
