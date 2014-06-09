if Spree.user_class
  Spree.user_class.class_eval do
    has_many :store_credits, :class_name => "Spree::StoreCredit", :order => 'refundable ASC, created_at DESC'
    has_many :withdrawals, :order => 'created_at DESC, transferred_at DESC'

    def has_store_credit?
      store_credits.where(status: true).present?
    end

    def store_credits_total
      store_credits.where(status: true).sum(:remaining_amount)
    end
    
    def credits_available_withdraw
      store_credits.where(status: true).where(refundable: true).where("created_at < ?", Date.today - 15.days)
    end

    def credits_available_withdraw_sum
      credits_available_withdraw.sum(:remaining_amount)
    end
    
    def credits_pending_withdraw
      withdrawals.where(transferred_at: nil)
    end
    
    def credits_pending_withdraw_sum
      credits_pending_withdraw.sum(:amount)
    end
    
    def withdraw_credits(amount)
      if amount == 0 || amount > credits_available_withdraw_sum
        return false
      else
        credits_available_withdraw.each do |store_credit|
          break if amount == 0
          if store_credit.remaining_amount > 0
            if store_credit.remaining_amount > amount
              store_credit.remaining_amount -= amount
              store_credit.save
              amount = 0
            else
              amount -= store_credit.remaining_amount
              store_credit.update_attribute(:remaining_amount, 0)
            end
          end
        end
        return true
      end
    end
    
    def statement
      (store_credits + withdrawals).sort_by{|l| l[:created_at]}
    end
    
  end
end
