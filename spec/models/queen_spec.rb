require 'rails_helper'

RSpec.describe Queen, type: :model do
  it "can move along a horizontal path" do
    game = FactoryBot.create(:game)
    queen = Queen.create(game_id: game.id, location_x: 4, location_y: 3)
    move = queen.valid_move?(1,3)

    expect(move).to be true
  end

  it "can move along a vertical path" do
    game = FactoryBot.create(:game)
    queen = Queen.create(game_id: game.id, location_x: 4, location_y: 3)
    move = queen.valid_move?(4,5)

    expect(move).to be true
  end

  it "can move along a true diagonal path" do
    game = FactoryBot.create(:game)
    queen = Queen.create(game_id: game.id, location_x: 4, location_y: 3)
    move = queen.valid_move?(6,5)

    expect(move).to be true
  end

  it "cannot move along a non-true diagonal path" do
    game = FactoryBot.create(:game)
    queen = Queen.create(game_id: game.id, location_x: 4, location_y: 3)
    move = queen.valid_move?(7,4)

    expect(move).to be false
  end

  it "cannot move outside the board" do
    game = FactoryBot.create(:game)
    queen = Queen.create(game_id: game.id, location_x: 4, location_y: 3)
    move = queen.valid_move?(8,3)

    expect(move).to be false
  end

  it "cannot move past an obstruction" do
    game = FactoryBot.create(:game)
    queen = Queen.create(game_id: game.id, location_x: 4, location_y: 3)
    pawn = Pawn.create(game_id: game.id, location_x: 3, location_y: 4)
    move = queen.valid_move?(2,5)
    
    expect(move).to be false
  end

  it "cannot land on a place with it's own piece" do
    game = FactoryBot.create(:game)
    queen = Queen.create(game_id: game.id, location_x: 2, location_y: 5, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 7, location_y: 5, white: true, notcaptured: true)
    
    queen.move_to!(7,5)
    pawn.reload
    queen.reload

    expect(pawn.notcaptured).to be true
    expect(queen.location_x).to eq 2
    expect(queen.location_y).to eq 5
    expect(pawn.location_x).to eq 7
    expect(pawn.location_y).to eq 5
  end

  it "can land on a place with an opponent's piece and capture that piece" do
    game = FactoryBot.create(:game)
    queen = Queen.create(game_id: game.id, location_x: 2, location_y: 5, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 7, location_y: 5, white: false, notcaptured: true)

    queen.move_to!(7,5)
    pawn.reload
    queen.reload

    expect(pawn.notcaptured).to be false
    expect(queen.location_x).to eq 7
    expect(queen.location_y).to eq 5
    expect(pawn.location_x).to be nil
    expect(pawn.location_y).to be nil
  end
end
