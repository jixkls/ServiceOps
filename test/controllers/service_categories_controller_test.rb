require "test_helper"

class ServiceCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @service_category = service_categories(:one)
  end

  test "should get index" do
    get service_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_service_category_url
    assert_response :success
  end

  test "should create service_category" do
    assert_difference("ServiceCategory.count") do
      post service_categories_url, params: { service_category: { active: @service_category.active, description: @service_category.description, name: @service_category.name } }
    end

    assert_redirected_to service_category_url(ServiceCategory.last)
  end

  test "should show service_category" do
    get service_category_url(@service_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_service_category_url(@service_category)
    assert_response :success
  end

  test "should update service_category" do
    patch service_category_url(@service_category), params: { service_category: { active: @service_category.active, description: @service_category.description, name: @service_category.name } }
    assert_redirected_to service_category_url(@service_category)
  end

  test "should destroy service_category without service orders" do
    service_category = service_categories(:two)
    assert_difference("ServiceCategory.count", -1) do
      delete service_category_url(service_category)
    end

    assert_redirected_to service_categories_url
  end

  test "should not destroy service_category that has service orders" do
    # service_categories(:one) está vinculado a ordens de serviço nos fixtures.
    assert_no_difference("ServiceCategory.count") do
      delete service_category_url(@service_category)
    end

    assert_redirected_to service_categories_url
    assert_not_nil flash[:alert]
  end
end
