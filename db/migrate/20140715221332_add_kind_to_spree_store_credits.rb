class AddKindToSpreeStoreCredits < ActiveRecord::Migration
  def change
    add_column :spree_store_credits, :kind, :integer
  end
end