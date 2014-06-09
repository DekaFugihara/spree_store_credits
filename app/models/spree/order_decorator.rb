Spree::Order.class_eval do
  has_many :withdrawals
  attr_accessible :store_credit_amount, :remove_store_credits
  attr_accessor :store_credit_amount, :remove_store_credits
  
  # the check for user? below is to ensure we don't break the
  # admin app when creating a new order from the admin console
  # In that case, we create an order before assigning a user
  before_save :process_store_credit, :if => "self.user.present? && @store_credit_amount"
  after_save :ensure_sufficient_credit, :if => "self.user.present? && !self.completed?"

  validates_with StoreCreditMinimumValidator

  def process_payments_with_credits!
    if total > 0 && pending_payments.empty?
      false
    else
      process_payments_without_credits!
    end
  end
  alias_method_chain :process_payments!, :credits
  
  def display_total_without_store_credits
    Spree::Money.new(total_without_store_credits, { currency: currency })
  end
  
  def total_without_store_credits
    item_total + adjustment_total + store_credit_amount
  end
  
  def store_credit_amount
    adjustments.store_credits.sum(:amount).abs.to_f
  end
  
  def store_credit_discount
    withdrawals.where(category: 1).sum(:amount)
  end

  # in case of paypal payment, item_total cannot be 0
  def store_credit_maximum_amount
    item_total
  end

  # returns the maximum usable amount of store credits
  def store_credit_maximum_usable_amount
    if user.store_credits_total > 0
      user.store_credits_total > store_credit_maximum_amount ? store_credit_maximum_amount : user.store_credits_total
    else
      0
    end
  end

  def refund_store_credits!
    withdrawals.each do |withdrawal|
      sc = withdrawal.store_credit
      sc.remaining_amount += withdrawal.amount
      sc.save
      withdrawal.update_attribute(:amount, 0)
    end
  end

  def store_credits
    order_scs = []
    if store_credit_amount > 0
      user_scs = user.store_credits.where(status: true).where("created_at < ?", completed_at)
      remaining_amount = store_credit_amount
      user_scs.each do |sc|
        remaining_amount_old = remaining_amount
        remaining_amount -= sc.amount
        remaining_amount = 0 if remaining_amount < 0 
        order_scs << [sc, remaining_amount_old - remaining_amount]
        break if remaining_amount == 0
      end
    end
    order_scs
  end

  private

  # credit or update store credit adjustment to correct value if amount specified
  #
  def process_store_credit
    @store_credit_amount = BigDecimal.new(@store_credit_amount.to_s).round(2)

    # store credit can't be greater than order total (not including existing credit), or the user's available credit
    @store_credit_amount = [@store_credit_amount, user.store_credits_total, (total + store_credit_amount.abs)].min

    if @store_credit_amount <= 0
      adjustments.store_credits.destroy_all
    else
      if sca = adjustments.store_credits.first
        sca.update_attributes({:amount => -(@store_credit_amount)})
      else
        # create adjustment off association to prevent reload
        sca = adjustments.store_credits.create(:label => I18n.t(:store_credit) , :amount => -(@store_credit_amount))
      end
    end

    # recalc totals and ensure payment is set to new amount
    update_totals
    pending_payments.first.amount = total if pending_payments.first
  end

  def consume_users_credit
    return unless completed? and user.present?
    credit_used = self.store_credit_amount
    user.store_credits.each do |store_credit|
      break if credit_used == 0
      if store_credit.remaining_amount > 0
        if store_credit.remaining_amount > credit_used
          withdrawal_amount = credit_used
          store_credit.remaining_amount -= withdrawal_amount
          store_credit.save
          credit_used = 0
        else
          withdrawal_amount = store_credit.remaining_amount
          credit_used -= withdrawal_amount
          store_credit.update_attribute(:remaining_amount, 0)
        end
        withdrawal_category = store_credit.refundable ? 2 : 1
        Spree::Withdrawal.create!(user_id: user.id, order_id: self.id, amount: withdrawal_amount, description: store_credit.id, category: withdrawal_category, transferred_at: Time.now)
      end
    end
  end
  # consume users store credit once the order has completed.
  state_machine.after_transition :to => :complete,  :do => :consume_users_credit

  # ensure that user has sufficient credits to cover adjustments
  #
  def ensure_sufficient_credit
    if user.store_credits_total < store_credit_amount
      # user's credit does not cover all adjustments.
      adjustments.store_credits.destroy_all

      update!
    end
  end

end
