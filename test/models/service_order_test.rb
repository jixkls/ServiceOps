require "test_helper"

class ServiceOrderTest < ActiveSupport::TestCase
  def build_order(attrs = {})
    ServiceOrder.new(
      { customer: customers(:one), service_category: service_categories(:one), title: "Teste" }.merge(attrs)
    )
  end

  test "sets defaults on create" do
    order = build_order
    assert order.save, order.errors.full_messages.to_sentence

    assert_equal "opened", order.status
    assert_equal "normal", order.priority
    assert_not_nil order.opened_at
    assert order.public_token.present?
    assert_match(/\AOS-\d{4}-[0-9A-F]{6}\z/, order.code)
  end

  test "does not override provided values" do
    order = build_order(status: "in_diagnosis", priority: "high")
    assert order.save

    assert_equal "in_diagnosis", order.status
    assert_equal "high", order.priority
  end

  test "requires a customer and a service category" do
    order = ServiceOrder.new(title: "Sem vínculos")
    assert_not order.valid?
    assert_includes order.errors[:customer], "must exist"
    assert_includes order.errors[:service_category], "must exist"
  end

  test "rejects an invalid priority" do
    order = build_order(priority: "altíssima")
    assert_not order.valid?
    assert_includes order.errors[:priority], "is not included in the list"
  end

  test "allows a permitted status transition" do
    order = build_order
    order.save!

    order.status = "in_diagnosis"
    assert order.valid?, order.errors.full_messages.to_sentence
  end

  test "blocks a forbidden status transition" do
    order = build_order
    order.save! # status opened

    order.status = "done" # opened não pode ir direto para done
    assert_not order.valid?
    assert_includes order.errors[:status].first, "não pode mudar"
  end

  test "blocks any transition out of a terminal status" do
    order = build_order(status: "done")
    order.save!

    order.status = "in_progress"
    assert_not order.valid?
  end
end
