class DevicesController < ApplicationController
  def index
    @devices = Device.includes(:macs)
  end
end
