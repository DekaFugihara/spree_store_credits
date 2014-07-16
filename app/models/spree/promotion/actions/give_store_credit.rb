module Spree
  class Promotion::Actions::GiveStoreCredit < PromotionAction
    preference :amount, :decimal, :default => 0.0
    preference :category, :integer, :default => 10
    attr_accessible :preferred_amount, :preferred_category

    def perform(options = {})
      reason = "#{promotion.name}"
      if user = options[:user]
        return if user.store_credits.where(:reason => reason).present?
        user.store_credits.create(:amount => preferred_amount, :remaining_amount => preferred_amount, :reason => reason, :category => preferred_category)
      end
    end
  end
end
