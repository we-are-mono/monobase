class Api::DevicesController < ActionController::API
  before_action :authenticate_with_api_key!

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: "Not found" }, status: :not_found
  end

  def create
    params.expect([ :num_macs ])

    @device = Device.create_device(device_params, params[:num_macs])
    if @device && @device.id
      puts 2
      render json: @device, status: :created
    else
      puts 3
      render json: { errors: @device.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    serial = params.extract_value(:id)
    @device = Device.where(serial_number: serial)
    render json: @device
  end

  def register
    params.expect([ :device_id, :qr1, :qr2 ])
    serial = params[:device_id]
    qr1, qr2 = params[:qr1], params[:qr2]
    @device = Device.find_by!(serial_number: serial)
    @device.update(qr1: qr1, qr2: qr2)
    render json: @device
  end

  private

  def device_params
    params.except(:num_macs).permit([ :qr1, :qr2, :product_group, :product_line, :hardware_revision, :pcb_version, :num_macs ])
  end

  def authenticate_with_api_key!
    api_key = request.headers["X-Api-Key"] || params[:api_key]
    @current_user = User.find_by(api_key: api_key)
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
