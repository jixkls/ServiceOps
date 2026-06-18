class ServiceOrder < ApplicationRecord
  # Status possíveis da ordem (o fluxo entre eles é controlado por ALLOWED_TRANSITIONS).
  STATUSES = %w[
    opened
    in_diagnosis
    waiting_quote_approval
    quote_approved
    quote_rejected
    in_progress
    waiting_payment
    done
    cancelled
  ].freeze

  PRIORITIES = %w[low normal high urgent].freeze

  # Transições de status permitidas: de qual status pode-se ir para quais.
  # Impede que a ordem "pule" para um status arbitrário.
  ALLOWED_TRANSITIONS = {
    "opened"                 => %w[in_diagnosis cancelled],
    "in_diagnosis"           => %w[waiting_quote_approval cancelled],
    "waiting_quote_approval" => %w[quote_approved quote_rejected cancelled],
    "quote_approved"         => %w[in_progress],
    "quote_rejected"         => %w[cancelled],
    "in_progress"            => %w[waiting_payment cancelled],
    "waiting_payment"        => %w[done cancelled],
    "done"                   => [],
    "cancelled"              => []
  }.freeze

  belongs_to :customer
  belongs_to :assigned_user, class_name: "User", optional: true
  belongs_to :service_category

  before_validation :set_defaults, on: :create

  validates :code, :status, :priority, :public_token, presence: true
  validates :code, :public_token, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validate :status_transition_must_be_allowed, on: :update

  private

  # Preenche automaticamente os campos gerados pelo sistema ao criar a ordem.
  def set_defaults
    self.status       ||= "opened"
    self.priority     ||= "normal"
    self.opened_at    ||= Time.current
    self.public_token ||= SecureRandom.urlsafe_base64(24)
    self.code         ||= "OS-#{Time.current.year}-#{SecureRandom.hex(3).upcase}"
  end

  # Quando o status muda, a transição precisa estar prevista em ALLOWED_TRANSITIONS.
  def status_transition_must_be_allowed
    return unless status_changed? && status_was.present?

    allowed = ALLOWED_TRANSITIONS.fetch(status_was, [])
    return if allowed.include?(status)

    errors.add(:status, "não pode mudar de '#{status_was}' para '#{status}'")
  end
end
