class DiagnosticsController < ApplicationController
  before_action :set_service_order
  before_action :set_diagnostic, only: %i[ edit update ]

  # GET /service_orders/1/diagnostic/new
  def new
    @diagnostic = @service_order.build_diagnostic
  end

  # GET /service_orders/1/diagnostic/edit
  def edit
  end

  # POST /service_orders/1/diagnostic
  def create
    @diagnostic = @service_order.build_diagnostic(diagnostic_params)
    # O autor do diagnóstico é sempre o usuário logado.
    @diagnostic.user = Current.user

    if @diagnostic.save
      redirect_to @service_order, notice: "Diagnóstico registrado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /service_orders/1/diagnostic
  def update
    if @diagnostic.update(diagnostic_params)
      redirect_to @service_order, notice: "Diagnóstico atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_service_order
      @service_order = ServiceOrder.find(params.expect(:service_order_id))
    end

    # Recurso singular: o diagnóstico é encontrado pela ordem, não por um id próprio.
    def set_diagnostic
      @diagnostic = @service_order.diagnostic
    end

    # Apenas campos preenchidos pelo usuário; o autor (user) vem do usuário logado.
    def diagnostic_params
      params.expect(diagnostic: [ :summary, :technical_details ])
    end
end
