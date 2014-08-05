# coding: utf-8
class Spree::Withdrawal < ActiveRecord::Base
  default_scope order('created_at DESC')
  attr_accessible :user_id, :order_id, :amount, :description, :category, :transferred_at, :order_number, :check_balance
  
  belongs_to :user
  belongs_to :order
  
  validates :amount, :presence => true, :numericality => true
  validates :user, :presence => true
  validates :category, :presence => true
  validate :enough_balance

  attr_accessor :order_number, :check_balance
  
  before_validation :associate_order
  after_create :withdraw_credits
  
  if Spree.user_class
    belongs_to :user, :class_name => Spree.user_class.to_s
  else
    belongs_to :user
    attr_accessible :amount, :description, :category
  end
  
  CATEGORIES_LIST = [["Pedido (Desconto)", 1], ["Pedido (Pagamento)", 2], ["Doação", 3], ["Saque PagSeguro", 4], ["Saque Conta Bancária", 5], ["Frete devolução", 6], ["Outra", 7]]

  def enough_balance
    errors.add(:amount, "superior ao saldo disponível para resgate") if check_balance.nil? && !user.enough_balance?(amount)
  end

  def associate_order
    self.order = Spree::Order.find_by_number(order_number) unless order_number.blank?
  end
  
  def withdraw_credits
    user.withdraw_credits(amount) if check_balance.nil?
  end
  
  def store_credit
    Spree::StoreCredit.find(description) if category <= 2
  end

  def category_name
    CATEGORIES_LIST.select{ |x| x[1] == self.category }[0][0]
  end
  
  def category_description
    name = category_name.gsub(/\(.*\)/, "")
    name += " #{self.order.number}" if category <= 2
    name += " para #{self.description}" if category == 3
    name += " #{self.description}" if category == 6
    name
  end
  
end
