require "test_helper"

class DiagnosticsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
  end

  test "should get new" do
    # A ordem :two ainda não tem diagnóstico.
    get new_service_order_diagnostic_url(service_orders(:two))
    assert_response :success
  end

  test "should get edit" do
    # A ordem :one já possui um diagnóstico (fixture).
    get edit_service_order_diagnostic_url(service_orders(:one))
    assert_response :success
  end

  test "should create diagnostic, set current user as author and move order to in_diagnosis" do
    order = ServiceOrder.create!(
      customer: customers(:one),
      service_category: service_categories(:one),
      title: "HD com ruído"
    )

    assert_difference("Diagnostic.count") do
      post service_order_diagnostic_url(order),
        params: { diagnostic: { summary: "Setores defeituosos", technical_details: "SMART acusando falhas." } }
    end

    assert_redirected_to service_order_url(order)
    assert_equal "in_diagnosis", order.reload.status
    assert_equal users(:one).id, order.diagnostic.user_id
  end

  test "should not create invalid diagnostic" do
    order = service_orders(:two)

    assert_no_difference("Diagnostic.count") do
      post service_order_diagnostic_url(order), params: { diagnostic: { summary: "" } }
    end

    assert_response :unprocessable_content
  end

  test "should update diagnostic" do
    patch service_order_diagnostic_url(service_orders(:one)),
      params: { diagnostic: { summary: "Resumo atualizado" } }

    assert_redirected_to service_order_url(service_orders(:one))
    assert_equal "Resumo atualizado", service_orders(:one).diagnostic.reload.summary
  end
end
