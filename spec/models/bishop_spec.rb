require 'rails_helper'

RSpec.describe Bishop, type: :model do
  
  it "can move along a true diagonal path" do
    game = FactoryBot.create(:game)
    bishop = Bishop.create(game_id: game.id, location_x: 4, location_y: 3, white: true)
    move = bishop.valid_move?(6,5)

    expect(move).to be true
  end

  it "cannot move along a non-true diagonal path" do
    game = FactoryBot.create(:game)
    bishop = Bishop.create(game_id: game.id, location_x: 4, location_y: 3, white: true)
    move = bishop.valid_move?(7,4)

    expect(move).to be false
  end

  it "cannot move outside the board" do
    game = FactoryBot.create(:game)
    bishop = Bishop.create(game_id: game.id, location_x: 5, location_y: 2)
    move = bishop.valid_move?(8,5)

    expect(move).to be false
  end

  it "cannot move past an obstruction" do
    game = FactoryBot.create(:game)
    bishop = Bishop.create(game_id: game.id, location_x: 4, location_y: 3, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 3, location_y: 4, white: false)
    move = bishop.valid_move?(2,5)
    
    expect(move).to be false
  end

  it "cannot land on a place with it's own piece" do
    game = FactoryBot.create(:game)
    bishop = Bishop.create(game_id: game.id, location_x: 2, location_y: 5, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 5, location_y: 2, white: true, notcaptured: true)
    
    bishop.move_to!(5,2)
    pawn.reload
    bishop.reload

    expect(pawn.notcaptured).to be true
    expect(bishop.location_x).to eq 2
    expect(bishop.location_y).to eq 5
    expect(pawn.location_x).to eq 5
    expect(pawn.location_y).to eq 2
  end

  it "can land on a place with an opponent's piece and capture that piece" do
    game = FactoryBot.create(:game)
    bishop = Bishop.create(game_id: game.id, location_x: 2, location_y: 5, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 5, location_y: 2, white: false, notcaptured: true)

    bishop.move_to!(5,2)
    pawn.reload
    bishop.reload

    expect(pawn.notcaptured).to be false
    expect(bishop.location_x).to eq 5
    expect(bishop.location_y).to eq 2
    expect(pawn.location_x).to be nil
    expect(pawn.location_y).to be nil
  end
end
