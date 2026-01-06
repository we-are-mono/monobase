class DevicesController < ApplicationController
  def index
    filter = params[:filter] || "registered"

    if filter == "all"
      @devices = Device.includes(:macs).all
    elsif filter == "packaged"
      @devices = Device.includes(:macs).where.not(packaged_date: nil)
    else
      @devices = Device.includes(:macs).where("qr1 IS NOT NULL AND qr2 IS NOT NULL")
    end

    @current_filter = filter
  end

  def package
  end

  def mark_as_packaged
    serial_number = params[:serial_number]
    device = Device.find_by(serial_number: serial_number)

    if device.nil?
      flash[:error] = "Device with serial number '#{serial_number}' not found."
      redirect_to package_devices_path
    else
      device.update(packaged_date: Time.current)
      flash[:notice] = "Device '#{serial_number}' has been marked as packaged at #{device.packaged_date.strftime('%Y-%m-%d %H:%M:%S')}."
      redirect_to package_devices_path
    end
  end
end
