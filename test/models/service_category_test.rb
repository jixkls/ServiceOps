require "test_helper"

class ServiceCategoryTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    category = ServiceCategory.new
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "cannot be destroyed when it has service orders" do
    category = service_categories(:one) # possui ordens nos fixtures
    assert_not category.destroy
    assert category.persisted?
  end

  test "can be destroyed when it has no service orders" do
    category = service_categories(:two)
    assert category.destroy
  end
end
