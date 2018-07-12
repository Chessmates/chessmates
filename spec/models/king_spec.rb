require 'rails_helper'

RSpec.describe King, type: :model do

  # King_Movement Tests: START =============
  it "shouldn't allow moves greater than 1 place at a time" do
    game = FactoryBot.create(:game)
    king = King.create(location_x: 4, location_y: 3, game_id: game.id)

    expect(king.valid_move?(2,3)).to be false # horizontal
    expect(king.valid_move?(2,5)).to be false # true diagonal
    expect(king.valid_move?(1,5)).to be false # false diagonal
    expect(king.valid_move?(4,5)).to be false # vertical
  end

  it "should allow vertical, horizontal or diagonal moves of 1 place at a time" do
    game = FactoryBot.create(:game)
    king = King.create(location_x: 4, location_y: 3, game_id: game.id)
   
   expect(king.valid_move?(5,3)).to be true # horizontal
   expect(king.valid_move?(5,2)).to be true # true diagonal
   expect(king.valid_move?(4,2)).to be true # vertical
  end

  it "shouldn't allow moves outside the chessboard" do
    game = FactoryBot.create(:game)
    king = King.create(location_x: 7, location_y: 3, game_id: game.id)
    
    expect(king.valid_move?(8,3)).to be false
  end
  # King_Movement Tests: END =============

  # Castling Tests: START =============
  # This tests do not account for whether game.check?(piece)
  it "can castle with white_rook_kingside when all conditions met" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 1, location_y: 0).destroy
    game.pieces.find_by(location_x: 2, location_y: 0).destroy
    game.reload
    white_king = game.pieces.find_by(location_x: 3, location_y: 0)

    expect(white_king.can_castle?(0,0,true)).to be true # kingside castle
    expect(white_king.can_castle?(7,0,true)).to be false # queenside castle
  end

  it "can castle with white_rook_queenside when all conditions met" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 4, location_y: 0).destroy
    game.pieces.find_by(location_x: 5, location_y: 0).destroy
    game.pieces.find_by(location_x: 6, location_y: 0).destroy
    game.reload
    white_king = game.pieces.find_by(location_x: 3, location_y: 0)

    expect(white_king.can_castle?(0,0,true)).to be false # kingside castle
    expect(white_king.can_castle?(7,0,true)).to be true # queenside castle
  end

  it "can castle with black_rook_kingside when all conditions met" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 1, location_y: 7).destroy
    game.pieces.find_by(location_x: 2, location_y: 7).destroy
    game.reload
    black_king = game.pieces.find_by(location_x: 3, location_y: 7)

    expect(black_king.can_castle?(0,7,true)).to be true # kingside castle
    expect(black_king.can_castle?(7,7,true)).to be false # queenside castle
  end

  it "can castle with black_rook_queenside when all conditions met" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 4, location_y: 7).destroy
    game.pieces.find_by(location_x: 5, location_y: 7).destroy
    game.pieces.find_by(location_x: 6, location_y: 7).destroy
    game.reload
    black_king = game.pieces.find_by(location_x: 3, location_y: 7)

    expect(black_king.can_castle?(0,7,true)).to be false # kingside castle
    expect(black_king.can_castle?(7,7,true)).to be true # queenside castle
  end

  it "castles with white_rook_kingside if can_castle" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 1, location_y: 0).destroy
    game.pieces.find_by(location_x: 2, location_y: 0).destroy
    game.reload
    white_king = game.pieces.find_by(location_x: 3, location_y: 0)

    white_king.castle!(0,0,true)

    expect(white_king.location_x).to eq 1 # white_king's new location_x
    expect(white_king.location_y).to eq 0 # white_king's new location_y

    expect(game.pieces.find_by(location_x: 2, location_y: 0).type).to eq "Rook"
    expect(game.pieces.find_by(location_x: 2, location_y: 0).white).to be true
  end

  it "castles with white_rook_queenside if can_castle" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 4, location_y: 0).destroy
    game.pieces.find_by(location_x: 5, location_y: 0).destroy
    game.pieces.find_by(location_x: 6, location_y: 0).destroy
    game.reload
    white_king = game.pieces.find_by(location_x: 3, location_y: 0)

    white_king.castle!(7,0,true)

    expect(white_king.location_x).to eq 5 # white_king's new location_x
    expect(white_king.location_y).to eq 0 # white_king's new location_y
    
    expect(game.pieces.find_by(location_x: 4, location_y: 0).type).to eq "Rook"
    expect(game.pieces.find_by(location_x: 4, location_y: 0).white).to be true
  end

  it "castles with black_rook_kingside if can_castle" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 1, location_y: 7).destroy
    game.pieces.find_by(location_x: 2, location_y: 7).destroy
    game.reload
    black_king = game.pieces.find_by(location_x: 3, location_y: 7)

    black_king.castle!(0,7,true)

    expect(black_king.location_x).to eq 1 # black_king's new location_x
    expect(black_king.location_y).to eq 7 # black_king's new location_y

    expect(game.pieces.find_by(location_x: 2, location_y: 7).type).to eq "Rook"
    expect(game.pieces.find_by(location_x: 2, location_y: 7).white).to be false
  end

  it "castles with black_rook_queenside if can_castle" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 4, location_y: 7).destroy
    game.pieces.find_by(location_x: 5, location_y: 7).destroy
    game.pieces.find_by(location_x: 6, location_y: 7).destroy
    game.reload
    black_king = game.pieces.find_by(location_x: 3, location_y: 7)

    black_king.castle!(7,7,true)

    expect(black_king.location_x).to eq 5 # black_king's new location_x
    expect(black_king.location_y).to eq 7 # black_king's new location_y
    
    expect(game.pieces.find_by(location_x: 4, location_y: 7).type).to eq "Rook"
    expect(game.pieces.find_by(location_x: 4, location_y: 7).white).to be false
  end
  # Castling Tests: END =============

  it "determines if a checked king can escape check" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    wking = King.create(game_id: game.id, location_x: 3, location_y: 0, white: true, notcaptured: true)
    bqueen = Queen.create(game_id: game.id, location_x: 3, location_y: 3, white: false, notcaptured: true)
    wpawn1 = Pawn.create(game_id: game.id, location_x: 1, location_y: 1, white: true, notcaptured: true)
    wpawn2 = Pawn.create(game_id: game.id, location_x: 2, location_y: 0, white: true, notcaptured: true)
    wpawn3 = Pawn.create(game_id: game.id, location_x: 4, location_y: 0, white: true, notcaptured: true)
    wpawn4 = Pawn.create(game_id: game.id, location_x: 4, location_y: 1, white: true, notcaptured: true)

    expect(wking.can_escape_check?).to be true
  end

  it "determines if a checked king cannot escape check" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    wking = King.create(game_id: game.id, location_x: 3, location_y: 0, white: true, notcaptured: true)
    bqueen = Queen.create(game_id: game.id, location_x: 3, location_y: 3, white: false, notcaptured: true)
    wpawn1 = Pawn.create(game_id: game.id, location_x: 2, location_y: 1, white: true, notcaptured: true)
    wpawn2 = Pawn.create(game_id: game.id, location_x: 2, location_y: 0, white: true, notcaptured: true)
    wpawn3 = Pawn.create(game_id: game.id, location_x: 4, location_y: 0, white: true, notcaptured: true)
    wpawn4 = Pawn.create(game_id: game.id, location_x: 4, location_y: 1, white: true, notcaptured: true)

    expect(wking.can_escape_check?).to be false
  end
end
