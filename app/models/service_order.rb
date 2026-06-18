class ServiceOrder < ApplicationRecord
  belongs_to :customer
  belongs_to :assigned_user, class_name: "User", optional: true
  belongs_to :service_category
end
