require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "shows the login form" do
    visit new_session_url

    assert_field "email_address"
    assert_field "password"
    assert_button "Sign in"
  end
end
