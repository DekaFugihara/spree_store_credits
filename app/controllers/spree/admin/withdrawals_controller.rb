module Spree
  class Admin::WithdrawalsController < Admin::ResourceController
    respond_to :xls, :html

    def index

      respond_with(@withdrawals) do |format|
        format.html
        format.xls do
          response.headers['Content-Disposition'] = 'attachment; filename="resgates.xls"'
        end
      end
    end
    
    # GET /withdrawals/1/edit
    def edit
      @withdrawal = Spree::Withdrawal.find(params[:id])
      @withdrawal.order_number = @withdrawal.order.number if @withdrawal.order
    end
    
    private

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
