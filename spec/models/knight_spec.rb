require 'rails_helper'

RSpec.describe Knight, type: :model do

  it "disallows any moves that are not L-Shaped (1 by 2 places)" do
    game = FactoryBot.create(:game)
    knight = Knight.create(location_x: 6, location_y: 3, game_id: game.id)

    twostep_horiz = knight.valid_move?(4,3)
    twostep_diag = knight.valid_move?(4,5)
    twostep_vert = knight.valid_move?(6,5)

    onestep_horiz = knight.valid_move?(7,3)
    onestep_diag = knight.valid_move?(7,2)
    onestep_vert = knight.valid_move?(6,2)

    expect(twostep_horiz).to be false
    expect(twostep_diag).to be false
    expect(twostep_vert).to be false

    expect(onestep_horiz).to be false
    expect(onestep_diag).to be false
    expect(onestep_vert).to be false
  end

  it "allows any moves that are L-Shaped (1 by 2 places)" do
    game = FactoryBot.create(:game)
    knight = Knight.create(location_x: 6, location_y: 3, game_id: game.id)

    move1 = knight.valid_move?(7,5)
    move2 = knight.valid_move?(5,5)
    move3 = knight.valid_move?(4,4)
    move4 = knight.valid_move?(4,2)

    expect(move1).to be true
    expect(move2).to be true
    expect(move3).to be true
    expect(move4).to be true
  end

  it "allows any moves that are obstructed (i.e. jump over pieces)" do
    game = FactoryBot.create(:game)
    knight = Knight.create(location_x: 6, location_y: 3, game_id: game.id)
    pawn1 = Pawn.create(location_x: 5, location_y: 3, game_id: game.id)
    pawn2 = Pawn.create(location_x: 6, location_y: 5, game_id: game.id)

    move1 = knight.valid_move?(4,2)
    move2 = knight.valid_move?(5,5)

    expect(move1).to be true
    expect(move2).to be true
  end

  it "disallows any moves outside the chessboard" do
    game = FactoryBot.create(:game)
    knight = Knight.create(location_x: 6, location_y: 3, game_id: game.id)

    move1 = knight.valid_move?(8,2)

    expect(move1).to be false
  end

  it "cannot land on a place with it's own piece" do
    game = FactoryBot.create(:game)
    knight = Knight.create(game_id: game.id, location_x: 2, location_y: 5, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 3, location_y: 3, white: true, notcaptured: true)

    knight.move_to!(3,3)
    pawn.reload
    knight.reload

    expect(pawn.notcaptured).to be true
    expect(knight.location_x).to eq 2
    expect(knight.location_y).to eq 5
    expect(pawn.location_x).to eq 3
    expect(pawn.location_y).to eq 3
  end

  it "can land on a place with an opponent's piece and capture that piece" do
    game = FactoryBot.create(:game)
    knight = Knight.create(game_id: game.id, location_x: 2, location_y: 5, white: true)
    pawn = Pawn.create(game_id: game.id, location_x: 3, location_y: 3, white: false, notcaptured: true)

    knight.move_to!(3,3)
    pawn.reload
    knight.reload

    expect(pawn.notcaptured).to be false
    expect(knight.location_x).to eq 3
    expect(knight.location_y).to eq 3
    expect(pawn.location_x).to be nil
    expect(pawn.location_y).to be nil
  end
end
