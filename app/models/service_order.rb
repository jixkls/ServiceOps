class ServiceOrder < ApplicationRecord
  STATUSES = %w[
    opened in_diagnosis waiting_quote_approval quote_approved quote_rejected
    in_progress waiting_payment done cancelled
  ].freeze

  PRIORITIES = %w[low normal high urgent].freeze

  ALLOWED_TRANSITIONS = {
    "opened" => %w[in_diagnosis cancelled],
    "in_diagnosis" => %w[waiting_quote_approval cancelled],
    "waiting_quote_approval" => %w[quote_approved quote_rejected cancelled],
    "quote_approved" => %w[in_progress],
    "quote_rejected" => %w[cancelled],
    "in_progress" => %w[waiting_payment cancelled],
    "waiting_payment" => %w[done cancelled],
    "done" => [],
    "cancelled" => []
  }.freeze

  belongs_to :customer
  belongs_to :assigned_user, class_name: "User", optional: true
  belongs_to :service_category
  has_one :diagnostic, dependent: :destroy
  has_many :status_histories, -> { order(created_at: :asc) }, dependent: :destroy

  before_validation :set_defaults, on: :create

  validates :code, :status, :priority, :public_token, presence: true
  validates :code, :public_token, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validate :must_start_opened, on: :create
  validate :status_transition_must_be_allowed, on: :update

  after_create :record_initial_status
  after_update :record_status_change, if: :saved_change_to_status?

  attr_accessor :status_history_context

  def allowed_next_statuses
    ALLOWED_TRANSITIONS.fetch(status, [])
  end

  def transition_to(next_status, note: nil, user: Current.user)
    transaction do
      self.status_history_context = { user: user, note: note }
      self.status = next_status
      self.finished_at = Time.current if next_status == "done"
      save!
    ensure
      self.status_history_context = nil
    end
  end

  def start_diagnosis!
    transition_to("in_diagnosis", note: "Diagnóstico registrado") if status == "opened"
  end

  private
    def set_defaults
      self.status ||= "opened"
      self.priority ||= "normal"
      self.opened_at ||= Time.current
      self.public_token ||= SecureRandom.urlsafe_base64(24)
      self.code ||= "OS-#{Time.current.year}-#{SecureRandom.hex(3).upcase}"
    end

    def must_start_opened
      errors.add(:status, "deve iniciar como aberta") unless status == "opened"
    end

    def status_transition_must_be_allowed
      return unless status_changed? && status_was.present?
      return if ALLOWED_TRANSITIONS.fetch(status_was, []).include?(status)

      errors.add(:status, "não pode mudar de '#{status_was}' para '#{status}'")
    end

    def record_initial_status
      status_histories.create!(to_status: status, user: Current.user, note: "Ordem aberta")
    end

    def record_status_change
      context = status_history_context || {}
      status_histories.create!(
        from_status: status_before_last_save,
        to_status: status,
        user: context[:user] || Current.user,
        note: context[:note]
      )
    end
end
