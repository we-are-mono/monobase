require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login" do
    get devices_index_url
    assert_redirected_to "/session/new"
  end
end
