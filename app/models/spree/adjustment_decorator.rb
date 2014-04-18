Spree::Adjustment.class_eval do
  attr_accessible :amount, :label, :source_type
  scope :store_credits, lambda { where(:source_type => 'Spree::StoreCredit') }
end