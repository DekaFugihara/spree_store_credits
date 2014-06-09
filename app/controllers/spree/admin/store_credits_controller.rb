module Spree
  class Admin::StoreCreditsController < Admin::ResourceController
    #before_filter :check_amounts, :only => [:edit, :update]
    #prepend_before_filter :set_remaining_amount, :only => [:create, :update]
    respond_to :xls, :html

    def index

      respond_with(@store_credits) do |format|
        format.html
        format.xls do
          response.headers['Content-Disposition'] = 'attachment; filename="creditos.xls"'
        end
      end
    end
    
    def users
      @users = Spree::StoreCredit.order("created_at DESC").collect {|sc| sc.user}.compact.uniq
    end
    
    private
    
    def check_amounts
      if (@store_credit.remaining_amount < @store_credit.amount)
        flash[:error] = I18n.t(:cannot_edit_used)
        redirect_to admin_store_credits_path
      end
    end

    def set_remaining_amount
      params[:store_credit][:remaining_amount] = params[:store_credit][:amount]
    end
    
    def collection
      return @collection if @collection.present?
      params[:q] ||= {}
      @search = super.ransack(params[:q])
      @collection = @search.result
      unless params[:format] == "xls"
        @collection = @collection.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end
      @collection
    end
    
  end
end
