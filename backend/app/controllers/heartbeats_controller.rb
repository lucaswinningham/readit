class HeartbeatsController < ApplicationController
  def show
    heartbeat = OpenStruct.new id: nil
    render json: HeartbeatSerializer.new(heartbeat), status: :ok
  end
end
