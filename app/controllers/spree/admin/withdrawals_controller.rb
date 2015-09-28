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

    def create
      @withdrawal = Spree::Withdrawal.new(params[:withdrawal])

      respond_to do |format|
        if @withdrawal.save
          format.html { redirect_to admin_user_path(params[:user_id]), notice: 'Resgate criado com sucesso.' }
          format.json { render json: @withdrawal, status: :created, location: @withdrawal }
        else
          format.html { render action: "new" }
          format.json { render json: @withdrawal.errors, status: :unprocessable_entity }
        end
      end
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
