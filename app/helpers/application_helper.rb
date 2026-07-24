module ApplicationHelper
  STATUS_LABELS = {
    "opened" => "Aberta",
    "in_diagnosis" => "Em diagnóstico",
    "waiting_quote_approval" => "Aguardando aprovação",
    "quote_approved" => "Orçamento aprovado",
    "quote_rejected" => "Orçamento recusado",
    "in_progress" => "Em execução",
    "waiting_payment" => "Aguardando pagamento",
    "done" => "Concluída",
    "cancelled" => "Cancelada"
  }.freeze

  def status_label(status)
    STATUS_LABELS.fetch(status, status.humanize)
  end

  def can_manage_customers?
    Current.user&.admin? || Current.user&.attendant?
  end

  def can_manage_categories?
    Current.user&.admin?
  end

  def can_manage_orders?
    Current.user&.admin? || Current.user&.attendant?
  end
end
