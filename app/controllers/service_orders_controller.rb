class ServiceOrdersController < ApplicationController
  before_action :set_service_order, only: %i[show edit update destroy transition]
  before_action :authorize_current_order, only: %i[show transition]
  before_action -> { require_role!(:admin, :attendant) }, only: %i[new create edit update]
  before_action -> { require_role!(:admin) }, only: :destroy

  def index
    @service_orders =
      if Current.user.technician?
        ServiceOrder.where(assigned_user: Current.user)
      else
        ServiceOrder.all
      end

    @service_orders = @service_orders.includes(:customer, :service_category, :assigned_user).order(created_at: :desc)
  end

  def show
  end

  def new
    @service_order = ServiceOrder.new
  end

  def edit
  end

  def create
    @service_order = ServiceOrder.new(service_order_params)

    if @service_order.save
      redirect_to @service_order, notice: "Ordem de serviço criada com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @service_order.update(service_order_params)
      redirect_to @service_order, notice: "Ordem de serviço atualizada com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def transition
    @service_order.transition_to(
      transition_params[:status],
      note: transition_params[:note],
      user: Current.user
    )
    redirect_to @service_order, notice: "Status atualizado com sucesso.", status: :see_other
  rescue ActiveRecord::RecordInvalid
    redirect_to @service_order, alert: @service_order.errors.full_messages.to_sentence, status: :see_other
  end

  def destroy
    @service_order.destroy!
    redirect_to service_orders_path, notice: "Ordem de serviço excluída.", status: :see_other
  end

  private
    def set_service_order
      @service_order = ServiceOrder.find(params.expect(:id))
    end

    def authorize_current_order
      authorize_service_order!(@service_order)
    end

    def service_order_params
      params.expect(service_order: %i[
        customer_id assigned_user_id service_category_id title description priority
      ])
    end

    def transition_params
      params.expect(service_order: %i[status note])
    end
end
