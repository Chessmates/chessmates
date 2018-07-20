class PiecesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "locations"
  end
end 