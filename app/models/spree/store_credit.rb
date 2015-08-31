# coding: utf-8
class Spree::StoreCredit < ActiveRecord::Base
  default_scope order('created_at DESC')
  attr_accessible :user_id, :amount, :reason, :remaining_amount, :category
                  
  before_save :set_refundable_option, :set_kind_option

  validates :amount, :presence => true, :numericality => true
  validates :reason, :presence => true
  validates :user, :presence => true
  if Spree.user_class
    belongs_to :user, :class_name => Spree.user_class.to_s
  else
    belongs_to :user
    attr_accessible :amount, :remaining_amount, :reason, :user_id
  end
  
  CATEGORIES_LIST = [["Sacola", 1], ["Presente", 2], ["Devolução", 3], ["Indicação de amigo", 5], ["Outra", 6], ["Troca", 7], ["Devolução de frete", 9], ["Natura", 10], ["Transferência", 11]]
  
  def set_refundable_option
    self.refundable = [1].include?(category) ? 1 : 0
  end

  # 1 = crédito tipo desconto / 2 = crédito tipo pagamento
  def set_kind_option
    self.kind = [2, 5].include?(category) ? 1 : 2
  end
  
  def category_name
    CATEGORIES_LIST.select{ |x| x[1] == self.category }[0][0] if self.category
  end
  
end
