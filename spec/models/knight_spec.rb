require 'rails_helper'

RSpec.describe Knight, type: :model do

  it "shouldn allow knights to move two places horizontal and one vert" do
    game = FactoryBot.create(:game)
    piece1 = Knight.create(location_x: 5, location_y: 4, game_id: game.id, white:true)
    piece1.save!
    piece1.valid_move?(7,5)
    expect(piece1.valid_move?(7,5)).to be true
  end

  it "shouldn allow knights to move one places horizontal and two vert" do
    game = FactoryBot.create(:game)
    piece1 = Knight.create(location_x: 5, location_y: 4, game_id: game.id, white:true)
    piece1.save!
    piece1.valid_move?(6,6)
    expect(piece1.valid_move?(6,6)).to be true
  end
end
