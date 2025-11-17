class Api::DevicesController < ActionController::API
  before_action :authenticate_with_api_key!

  def create
    if !params[:num_macs]
      render json: { errors: [ "Param num_macs must be present" ] }
      return
    end

    ActiveRecord::Base.transaction do
      @device = Device.new(device_params)
      if @device.save
        next_macs =  Mac.where(device_id: nil).order(:addr).limit(params[:num_macs])
        Mac.where(id: next_macs.select(:id)).update_all(device_id: @device.id)
        render json: @device, status: :created
      else
        render json: { errors: @device.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def show
    serial = params.extract_value(:id)
    @device = Device.where(serial_number: serial)
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
