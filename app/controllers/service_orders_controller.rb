class ServiceOrdersController < ApplicationController
  before_action :set_service_order, only: %i[ show edit update destroy ]

  # GET /service_orders or /service_orders.json
  def index
    @service_orders = ServiceOrder.all
  end

  # GET /service_orders/1 or /service_orders/1.json
  def show
  end

  # GET /service_orders/new
  def new
    @service_order = ServiceOrder.new
  end

  # GET /service_orders/1/edit
  def edit
  end

  # POST /service_orders or /service_orders.json
  def create
    @service_order = ServiceOrder.new(service_order_params)

    respond_to do |format|
      if @service_order.save
        format.html { redirect_to @service_order, notice: "Service order was successfully created." }
        format.json { render :show, status: :created, location: @service_order }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @service_order.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /service_orders/1 or /service_orders/1.json
  def update
    respond_to do |format|
      if @service_order.update(service_order_params)
        format.html { redirect_to @service_order, notice: "Service order was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @service_order }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @service_order.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /service_orders/1 or /service_orders/1.json
  def destroy
    @service_order.destroy!

    respond_to do |format|
      format.html { redirect_to service_orders_path, notice: "Service order was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service_order
      @service_order = ServiceOrder.find(params.expect(:id))
    end

    # Apenas campos preenchidos pelo usuário.
    # code, status, public_token e opened_at são gerados pelo model (ver ServiceOrder#set_defaults);
    # status muda só pelas regras de transição, e finished_at é definido pelo fluxo de finalização.
    def service_order_params
      params.expect(service_order: [ :customer_id, :assigned_user_id, :service_category_id, :title, :description, :priority ])
    end
end
