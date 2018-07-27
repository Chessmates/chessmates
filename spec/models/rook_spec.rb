require 'rails_helper'

RSpec.describe Rook, type: :model do

  it "can move vertically on board" do
    game = FactoryBot.create(:game)
    rook = Rook.create(location_x: 4, location_y: 3, game_id: game.id, white: true)

    expect(rook.valid_move?(4,5)).to be true
  end

  it "can move horizontally on board" do
    game = FactoryBot.create(:game)
    rook = Rook.create(location_x: 4, location_y: 3, game_id: game.id, white: true)

    expect(rook.valid_move?(1,3)).to be true
  end

  it "cannot move outside the chessboard" do
    game = FactoryBot.create(:game)
    rook = Rook.create(location_x: 4, location_y: 3, game_id: game.id)

    expect(rook.valid_move?(8,3)).to be false
  end

  it "cannot move past an obstruction" do
    game = FactoryBot.create(:game)
    rook = Rook.create(location_x: 4, location_y: 3, game_id: game.id, white: true)
    pawn = Pawn.create(location_x: 2, location_y: 3, game_id: game.id)

    expect(rook.valid_move?(1,3)).to be false
  end

  it "cannot move non-linearly (true or false diagonal) on the board" do
    game = FactoryBot.create(:game)
    rook = Rook.create(location_x: 4, location_y: 3, game_id: game.id, white: true)

    expect(rook.valid_move?(2,5)).to be false
    expect(rook.valid_move?(7,5)).to be false
  end

  it "cannot land on a place with it's own piece" do
    game = FactoryBot.create(:game)
    rook = Rook.create(game_id: game.id, location_x: 2, location_y: 5, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 7, location_y: 5, white: true, notcaptured: true)
    
    rook.move_to!(7,5)
    pawn.reload
    rook.reload

    expect(pawn.notcaptured).to be true
    expect(rook.location_x).to eq 2
    expect(rook.location_y).to eq 5
    expect(pawn.location_x).to eq 7
    expect(pawn.location_y).to eq 5
  end

  it "can land on a place with an opponent's piece and capture that piece" do
    game = FactoryBot.create(:game)
    rook = Rook.create(game_id: game.id, location_x: 2, location_y: 5, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 7, location_y: 5, white: false, notcaptured: true)

    rook.move_to!(7,5)
    pawn.reload
    rook.reload

    expect(pawn.notcaptured).to be false
    expect(rook.location_x).to eq 7
    expect(rook.location_y).to eq 5
    expect(pawn.location_x).to be nil
    expect(pawn.location_y).to be nil
  end
end
