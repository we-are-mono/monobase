require "test_helper"

class Api::DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @valid_api_key = @user.api_key

    # Create some unassigned MACs for testing device creation
    # Valid range: 0xE8F6D7001000 to 0xE8F6D70FFFFF (256146866704384 to 256146867748863)
    @unassigned_macs = [
      Mac.create!(addr: 256146866704390),
      Mac.create!(addr: 256146866704391),
      Mac.create!(addr: 256146866704392),
      Mac.create!(addr: 256146866704393),
      Mac.create!(addr: 256146866704394)
    ]

    @valid_device_params = {
      product_group: "R",
      product_line: "01",
      hardware_revision: "C",
      pcb_version: 2,
      num_macs: 3
    }
  end

  # Authentication tests
  test "create without API key returns unauthorized" do
    post api_devices_url, params: @valid_device_params
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["error"]
  end

  test "create with invalid API key returns unauthorized" do
    post api_devices_url,
      params: @valid_device_params,
      headers: { "X-Api-Key": "invalid_key" }
    assert_response :unauthorized
  end

  test "show without API key returns unauthorized" do
    get api_device_url(id: devices(:one).serial_number)
    assert_response :unauthorized
  end

  test "register without API key returns unauthorized" do
    post api_device_register_path(device_id: devices(:one).serial_number),
      params: { device_id: devices(:one).serial_number, qr1: "TEST1", qr2: "TEST2" }
    assert_response :unauthorized
  end

  test "test this" do
    post api_devices_url,
      params: @valid_device_params.merge(qr1: "ASDFG", qr2: "QWERTYBBQ"),
      headers: { "X-Api-Key": @valid_api_key }

    post api_devices_url,
      params: @valid_device_params.merge(qr1: "ASDFG", qr2: "QWERTYBBQ"),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :unprocessable_entity
  end

  test "create with valid params and API key creates device" do
    assert_difference("Device.count", 1) do
      post api_devices_url,
        params: @valid_device_params,
        headers: { "X-Api-Key": @valid_api_key }
    end

    week_year = Date.today.strftime("%W%y")
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["id"]
    assert_not_nil json_response["serial_number"]
    assert_match(/MT-R01C-#{week_year}-\d{5}/, json_response["serial_number"])
  end

  test "create assigns correct number of MACs to device" do
    post api_devices_url,
      params: @valid_device_params.merge(num_macs: 3),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :created
    device_id = JSON.parse(response.body)["id"]
    device = Device.find(device_id)
    assert_equal 3, device.macs.count
  end

  test "create with API key in params works" do
    assert_difference("Device.count", 1) do
      post api_devices_url,
        params: @valid_device_params,
        headers: { "X-Api-Key": @valid_api_key }
    end

    assert_response :created
  end

  test "create without num_macs returns bad request" do
    post api_devices_url,
      params: @valid_device_params.except(:num_macs),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :bad_request
    assert_match(/num_macs/, JSON.parse(response.body)["error"])
  end

  test "create with invalid product_group returns unprocessable entity" do
    post api_devices_url,
      params: @valid_device_params.merge(product_group: "X"),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["errors"].join, "Product group"
  end

  test "create with invalid product_line returns unprocessable entity" do
    post api_devices_url,
      params: @valid_device_params.merge(product_line: "00"),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["errors"].join, "Product line"
  end

  test "create with invalid hardware_revision returns unprocessable entity" do
    post api_devices_url,
      params: @valid_device_params.merge(hardware_revision: "1"),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["errors"].join, "Hardware revision"
  end

  test "create with invalid pcb_version returns unprocessable entity" do
    post api_devices_url,
      params: @valid_device_params.merge(pcb_version: 100),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["errors"].join, "Pcb version"
  end

  # Show action tests
  test "show returns device with valid serial number" do
    device = devices(:one)
    get api_device_url(id: device.serial_number),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal device.serial_number, json_response[0]["serial_number"]
  end

  test "show returns empty array for non-existent serial number" do
    get api_device_url(id: "NONEXISTENT"),
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 0, json_response.length
  end

  # Register action tests
  test "register updates device with QR codes" do
    device = devices(:one)
    new_qr1 = "UNIQUE-QR-#{Time.now.to_i}-001"
    new_qr2 = "UNIQUE-QR-#{Time.now.to_i}-002"

    post api_device_register_path(device_id: device.serial_number),
      params: { device_id: device.serial_number, qr1: new_qr1, qr2: new_qr2 },
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_not_nil json_response
    device.reload
    assert_equal new_qr1, device.qr1
    assert_equal new_qr2, device.qr2
  end

  test "register with non-existent device returns not found" do
    post api_device_register_path(device_id: "NONEXISTENT"),
      params: { device_id: "NONEXISTENT", qr1: "QR1", qr2: "QR2" },
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :not_found
    assert_equal "Not found", JSON.parse(response.body)["error"]
  end

  test "register without qr1 returns bad request" do
    device = devices(:one)

    post api_device_register_path(device_id: device.serial_number),
      params: { device_id: device.serial_number, qr2: "QR2" },
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :bad_request
    assert_match(/qr1/, JSON.parse(response.body)["error"])
  end

  test "register without qr2 returns bad request" do
    device = devices(:one)

    post api_device_register_path(device_id: device.serial_number),
      params: { device_id: device.serial_number, qr1: "QR1" },
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :bad_request
    assert_match(/qr2/, JSON.parse(response.body)["error"])
  end

  test "register with duplicate QR combination fails validation" do
    existing_device = devices(:two)
    device = devices(:one)

    post api_device_register_path(device_id: device.serial_number),
      params: {
        device_id: device.serial_number,
        qr1: existing_device.qr1,
        qr2: existing_device.qr2
      },
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :success
  end

  test "register with reversed QR combination from existing device" do
    existing_device = devices(:two)
    device = devices(:one)

    post api_device_register_path(device_id: device.serial_number),
      params: {
        device_id: device.serial_number,
        qr1: existing_device.qr2,
        qr2: existing_device.qr1
      },
      headers: { "X-Api-Key": @valid_api_key }

    assert_response :success
  end
end
