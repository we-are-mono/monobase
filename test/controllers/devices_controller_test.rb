require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should redirect to login when not authenticated" do
    get devices_index_url
    assert_redirected_to "/session/new"
  end

  test "should get index when authenticated" do
    sign_in_as @user
    get devices_index_url
    assert_response :success
  end

  test "should load devices with their macs" do
    sign_in_as @user
    get devices_index_url
    assert_response :success
    devices = @controller.instance_variable_get(:@devices)
    assert_equal devices.count, 2
  end
end
