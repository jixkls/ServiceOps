class Diagnostic < ApplicationRecord
  # Cada ordem tem no máximo um diagnóstico (garantido por índice único no banco).
  belongs_to :service_order
  # Técnico que registrou a análise.
  belongs_to :user

  validates :summary, presence: true
  # Reforça no nível de aplicação o índice único do banco (um diagnóstico por ordem).
  validates :service_order_id, uniqueness: true

  # Ao registrar o diagnóstico, a ordem sai de "opened" para "in_diagnosis".
  after_create :start_order_diagnosis

  private

  def start_order_diagnosis
    service_order.start_diagnosis!
  end
end
