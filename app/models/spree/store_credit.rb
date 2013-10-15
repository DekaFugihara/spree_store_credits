# coding: utf-8
class Spree::StoreCredit < ActiveRecord::Base
  attr_accessible :user_id, :amount, :reason, :remaining_amount, :status, :withdrawal_info, :category
                  
  before_save :set_refundable_option

  validates :amount, :presence => true, :numericality => true
  validates :reason, :presence => true
  validates :user, :presence => true
  if Spree.user_class
    belongs_to :user, :class_name => Spree.user_class.to_s
  else
    belongs_to :user
    attr_accessible :amount, :remaining_amount, :reason, :user_id
  end
  
  CATEGORIES_LIST = [["Sacola", 1], ["Presente", 2], ["Devolução", 3], ["Saque", 4], ["Indicação de amigo", 5], ["Outra", 6]]
  
  def set_refundable_option
    self.refundable = category == 2 ? 0 : 1
  end
  
end
