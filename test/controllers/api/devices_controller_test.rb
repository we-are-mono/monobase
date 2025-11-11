require "test_helper"

class Api::DevicesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    post api_devices_url, params: "qr1=BBQ&qr2=ZOFA&product_group=R&product_line=01&hardware_revision=C&pcb_version=2&num_macs=5"
    assert_response :success
  end
end
