require "test_helper"

class ServiceOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @service_order = service_orders(:one)
  end

  test "should get index" do
    get service_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_service_order_url
    assert_response :success
  end

  test "should create service_order" do
    assert_difference("ServiceOrder.count") do
      post service_orders_url, params: { service_order: { assigned_user_id: @service_order.assigned_user_id, code: @service_order.code, customer_id: @service_order.customer_id, description: @service_order.description, finished_at: @service_order.finished_at, opened_at: @service_order.opened_at, priority: @service_order.priority, public_token: @service_order.public_token, service_category_id: @service_order.service_category_id, status: @service_order.status, title: @service_order.title } }
    end

    assert_redirected_to service_order_url(ServiceOrder.last)
  end

  test "should show service_order" do
    get service_order_url(@service_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_service_order_url(@service_order)
    assert_response :success
  end

  test "should update service_order" do
    patch service_order_url(@service_order), params: { service_order: { assigned_user_id: @service_order.assigned_user_id, code: @service_order.code, customer_id: @service_order.customer_id, description: @service_order.description, finished_at: @service_order.finished_at, opened_at: @service_order.opened_at, priority: @service_order.priority, public_token: @service_order.public_token, service_category_id: @service_order.service_category_id, status: @service_order.status, title: @service_order.title } }
    assert_redirected_to service_order_url(@service_order)
  end

  test "should destroy service_order" do
    assert_difference("ServiceOrder.count", -1) do
      delete service_order_url(@service_order)
    end

    assert_redirected_to service_orders_url
  end
end
