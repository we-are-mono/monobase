require "test_helper"

class Api::DevicesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_devices_create_url
    assert_response :success
  end
end
