class StatusHistory < ApplicationRecord
  belongs_to :service_order
  belongs_to :user, optional: true

  validates :to_status, presence: true, inclusion: { in: ServiceOrder::STATUSES }
  validates :from_status, inclusion: { in: ServiceOrder::STATUSES }, allow_nil: true
end
