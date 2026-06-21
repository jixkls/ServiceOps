json.extract! service_order, :id, :code, :customer_id, :assigned_user_id, :service_category_id, :title, :description, :status, :priority, :public_token, :opened_at, :finished_at, :created_at, :updated_at
json.url service_order_url(service_order, format: :json)
