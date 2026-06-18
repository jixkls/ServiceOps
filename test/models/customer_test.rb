require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    customer = Customer.new(email: "x@example.com")
    assert_not customer.valid?
    assert_includes customer.errors[:name], "can't be blank"
  end

  test "cannot be destroyed when it has service orders" do
    customer = customers(:one) # possui ordens nos fixtures
    assert_not customer.destroy
    assert customer.persisted?
  end

  test "can be destroyed when it has no service orders" do
    customer = customers(:two)
    assert customer.destroy
  end
end
