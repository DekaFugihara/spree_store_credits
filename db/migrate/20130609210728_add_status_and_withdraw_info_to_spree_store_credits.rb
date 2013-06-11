class AddStatusAndWithdrawInfoToSpreeStoreCredits < ActiveRecord::Migration
  def change
    add_column :spree_store_credits, :status, :boolean, :default => true
    add_column :spree_store_credits, :withdrawal_info, :text
  end
end
