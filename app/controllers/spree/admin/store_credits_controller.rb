module Spree
  class Admin::StoreCreditsController < Admin::ResourceController
    #before_filter :check_amounts, :only => [:edit, :update]
    #prepend_before_filter :set_remaining_amount, :only => [:create, :update]
    respond_to :xls, :html

    def create
      @store_credit = Spree::StoreCredit.new(params[:store_credit])

      respond_to do |format|
        if @store_credit.save
          format.html { redirect_to admin_user_path(params[:user_id]), notice: 'Store credit was successfully created.' }
          format.json { render json: @store_credit, status: :created, location: @store_credit }
        else
          format.html { render action: "new" }
          format.json { render json: @store_credit.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      @store_credit = Spree::StoreCredit.find(params[:store_credit][:id])

      respond_to do |format|
        if @store_credit.update_attributes(params[:store_credit])
          format.html { redirect_to admin_user_path(@store_credit.user), notice: 'Store Credit atualizado com sucesso.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @product_brand.errors, status: :unprocessable_entity }
        end
      end
    end

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
