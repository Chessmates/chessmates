require 'rails_helper'

RSpec.describe King, type: :model do

  # King_Movement Tests: START =============
  it "shouldn't allow a movement other than 1 place at a time" do
    game = FactoryBot.create(:game)
    piece1 = King.create(location_x: 2, location_y: 7, game_id: game.id)
    piece1.save!
    piece1.valid_move?(2,9)
    expect(piece1.valid_move?(2,9)).to be false
  end

  it "should allow a movement of 1 place at a time" do
    game = FactoryBot.create(:game)
    piece1 = King.create(location_x: 2, location_y: 7, game_id: game.id)
    piece1.save!
    piece1.valid_move?(2,6)
    expect(piece1.valid_move?(2,6)).to be true
  end

  it "should allow diagonal moves of 1 place at a time" do
    game = FactoryBot.create(:game)
    piece1 = King.create(location_x: 3, location_y: 5, game_id: game.id)
    piece1.save!
    piece1.valid_move?(2,4)
    expect(piece1.valid_move?(2,4)).to be true
  end

  it "shouldn't allow moves outside the 8x8 table" do
    game = FactoryBot.create(:game)
    piece1 = King.create(location_x: 1, location_y: 1, game_id: game.id)
    piece1.save!
    piece1.valid_move?(9,9)
    expect(piece1.valid_move?(9,9)).to be false
  end
  # King_Movement Tests: END =============

  # Castling Tests: START =============
  # This tests do not account for whether game.check?(piece)
  it "can castle white_king and white_rook_kingside when all conditions met" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 1, location_y: 0).destroy
    game.pieces.find_by(location_x: 2, location_y: 0).destroy
    game.reload
    white_king = game.pieces.find_by(location_x: 3, location_y: 0)

    expect(white_king.can_castle?(0,0)).to be true # kingside castle
    expect(white_king.can_castle?(7,0)).to be false # queenside castle
  end

  it "can castle white_king and white_rook_queenside when all conditions met" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 4, location_y: 0).destroy
    game.pieces.find_by(location_x: 5, location_y: 0).destroy
    game.pieces.find_by(location_x: 6, location_y: 0).destroy
    game.reload
    white_king = game.pieces.find_by(location_x: 3, location_y: 0)

    expect(white_king.can_castle?(0,0)).to be false # kingside castle
    expect(white_king.can_castle?(7,0)).to be true # queenside castle
  end

  it "can castle black_king and black_rook_kingside when all conditions met" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 1, location_y: 7).destroy
    game.pieces.find_by(location_x: 2, location_y: 7).destroy
    game.reload
    black_king = game.pieces.find_by(location_x: 0, location_y: 7)

    expect(black_king.can_castle?(0,7)).to be true # kingside castle
    expect(black_king.can_castle?(7,7)).to be false # queenside castle
  end

  it "can castle black_king and black_rook_queenside when all conditions met" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 4, location_y: 7).destroy
    game.pieces.find_by(location_x: 5, location_y: 7).destroy
    game.pieces.find_by(location_x: 6, location_y: 7).destroy
    game.reload
    black_king = game.pieces.find_by(location_x: 0, location_y: 7)

    expect(black_king.can_castle?(0,7)).to be true # kingside castle
    expect(black_king.can_castle?(7,7)).to be false # queenside castle
  end

  it "castles white_king and white_rook_kingside if can_castle" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 1, location_y: 0).destroy
    game.pieces.find_by(location_x: 2, location_y: 0).destroy
    game.reload
    white_king = game.pieces.find_by(location_x: 3, location_y: 0)

    white_king.castle!(0,0)

    expect(white_king.location_x).to eq 1 # white_king's new location_x
    expect(white_king.location_y).to eq 0 # white_king's new location_y

    expect(game.pieces.find_by(location_x: 2, location_y: 0).type).to eq "Rook"
    expect(game.pieces.find_by(location_x: 2, location_y: 0).white).to be true
  end

  it "castles white_king and white_rook_queenside if can_castle" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 4, location_y: 0).destroy
    game.pieces.find_by(location_x: 5, location_y: 0).destroy
    game.pieces.find_by(location_x: 6, location_y: 0).destroy
    game.reload
    white_king = game.pieces.find_by(location_x: 3, location_y: 0)

    white_king.castle!(7,0)

    expect(white_king.location_x).to eq 5 # white_king's new location_x
    expect(white_king.location_y).to eq 0 # white_king's new location_y
    
    expect(game.pieces.find_by(location_x: 4, location_y: 0).type).to eq "Rook"
    expect(game.pieces.find_by(location_x: 4, location_y: 0).white).to be true
  end

  it "castles black_king and black_rook_kingside if can_castle" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 1, location_y: 7).destroy
    game.pieces.find_by(location_x: 2, location_y: 7).destroy
    game.reload
    black_king = game.pieces.find_by(location_x: 3, location_y: 7)

    black_king.castle!(0,7)

    expect(black_king.location_x).to eq 1 # black_king's new location_x
    expect(black_king.location_y).to eq 7 # black_king's new location_y

    expect(game.pieces.find_by(location_x: 2, location_y: 7).type).to eq "Rook"
    expect(game.pieces.find_by(location_x: 2, location_y: 7).white).to be false
  end

  it "castles black_king and black_rook_queenside if can_castle" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 4, location_y: 7).destroy
    game.pieces.find_by(location_x: 5, location_y: 7).destroy
    game.pieces.find_by(location_x: 6, location_y: 7).destroy
    game.reload
    black_king = game.pieces.find_by(location_x: 3, location_y: 7)

    black_king.castle!(7,7)

    expect(black_king.location_x).to eq 5 # black_king's new location_x
    expect(black_king.location_y).to eq 7 # black_king's new location_y
    
    expect(game.pieces.find_by(location_x: 4, location_y: 7).type).to eq "Rook"
    expect(game.pieces.find_by(location_x: 4, location_y: 7).white).to be false
  end
  # Castling Tests: END =============
end
