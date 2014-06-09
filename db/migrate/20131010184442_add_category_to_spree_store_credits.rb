class AddCategoryToSpreeStoreCredits < ActiveRecord::Migration
  def change
    add_column :spree_store_credits, :category, :integer
    add_column :spree_store_credits, :refundable, :boolean, :default => true
  end
end