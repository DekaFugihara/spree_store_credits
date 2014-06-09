# coding: utf-8
class Spree::Withdrawal < ActiveRecord::Base
  default_scope order('created_at DESC')
  attr_accessible :user_id, :order_id, :amount, :description, :category, :transferred_at, :order_number
  
  belongs_to :user
  belongs_to :order
  
  validates :amount, :presence => true, :numericality => true
  validates :user, :presence => true
  validates :category, :presence => true
  
  attr_accessor :order_number
  
  before_validation :associate_order
  
  if Spree.user_class
    belongs_to :user, :class_name => Spree.user_class.to_s
  else
    belongs_to :user
    attr_accessible :amount, :description, :category
  end
  
  CATEGORIES_LIST = [["Pedido (Desconto)", 1], ["Pedido (Pagamento)", 2], ["Doação", 3], ["Saque PagSeguro", 4], ["Saque Itau", 5], ["Frete", 6], ["Outra", 7]]

  def associate_order
    self.order = Spree::Order.find_by_number(order_number) unless order_number.blank?
  end
  
  def store_credit
    Spree::StoreCredit.find(description) if category < 3
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
