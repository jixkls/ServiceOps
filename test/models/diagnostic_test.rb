require "test_helper"

class DiagnosticTest < ActiveSupport::TestCase
  test "exige resumo" do
    diagnostic = Diagnostic.new(service_order: service_orders(:two), user: users(:one))
    assert_not diagnostic.valid?
    assert_includes diagnostic.errors[:summary], "can't be blank"
  end

  test "permite apenas um diagnóstico por ordem" do
    # A ordem :one já possui um diagnóstico (fixture).
    duplicate = Diagnostic.new(service_order: service_orders(:one), user: users(:one), summary: "Outro")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:service_order_id], "has already been taken"
  end

  test "ao criar diagnóstico a ordem aberta vai para in_diagnosis" do
    order = ServiceOrder.create!(
      customer: customers(:one),
      service_category: service_categories(:one),
      title: "Teclado falhando"
    )
    assert_equal "opened", order.status

    order.create_diagnostic!(user: users(:one), summary: "Teclas travando")

    assert_equal "in_diagnosis", order.reload.status
  end

  test "criar diagnóstico não altera ordem que não está aberta" do
    # A ordem :two está em in_diagnosis e ainda não tem diagnóstico.
    order = service_orders(:two)
    assert_equal "in_diagnosis", order.status

    order.create_diagnostic!(user: users(:one), summary: "Análise")

    assert_equal "in_diagnosis", order.reload.status
  end
end
