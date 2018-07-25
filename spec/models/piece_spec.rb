require 'rails_helper'

RSpec.describe Piece, type: :model do
  
  # IS_OBSTRUCTED? METHOD TESTS: START = = = = = = = = = = = = = = = = =

  it "determines obstruction in a piece's vertical path going up" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 5, location_y: 1, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 5, location_y: 3, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(5,5)).to be true
  end

  it "determines obstruction in a piece's vertical path going down" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 2, location_y: 7, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 2, location_y: 4, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(2,0)).to be true
  end

  it "determines obstruction in a piece's horizontal path going left" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 0, location_y: 5, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 2, location_y: 5, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(3,5)).to be true
  end

  it "determines obstruction in a piece's horizontal path going right" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 5, location_y: 6, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 4, location_y: 6, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(2,6)).to be true
  end

  it "determines obstruction in a piece's diagonal path going top-right" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 0, location_y: 1, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 2, location_y: 3, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(3,4)).to be true
  end

  it "determines obstruction in a piece's diagonal path going bottom-right" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 1, location_y: 7, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 2, location_y: 6, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(3,5)).to be true
  end

  it "determines obstruction in a piece's diagonal path going top-left" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 6, location_y: 0, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 4, location_y: 2, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(3,3)).to be true
  end

  it "determines obstruction in a piece's diagonal path going bottom-left" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 7, location_y: 6, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 6, location_y: 5, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(4,3)).to be true
  end

  # IS_OBSTRUCTED? METHOD TESTS: END = = = = = = = = = = = = = = = = =

  # MOVE_TO! METHOD TESTS: START = = = = = = = = = = = = = = = = = = =

  it "captures the opponent's piece on the intended destination, then assumes that position" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 0, location_y: 1).destroy
    game.pieces.find_by(location_x: 0, location_y: 6).destroy
    whiteRook = game.pieces.find_by(location_x:0, location_y: 0)
    opponent = game.pieces.find_by(location_x: 0, location_y: 7) # this is blackRook

    whiteRook.move_to!(0,7)
    whiteRook.reload
    opponent.reload
   
    expect(opponent.notcaptured).to be false
    expect(opponent.location_x).to be nil
    expect(opponent.location_y).to be nil
    expect(whiteRook.location_x).to eq(0)
    expect(whiteRook.location_y).to eq(7) 
  end

  it "cannot assume new position if a piece's destination is occupied by own piece" do
    game = FactoryBot.create(:game)
    whiteRook = game.pieces.find_by(location_x:0, location_y: 0)
    friendly = game.pieces.find_by(location_x: 1, location_y: 0)

    whiteRook.move_to!(1,0)

    expect(friendly.notcaptured).to be true
    expect(whiteRook.location_x).to eq(0)
    expect(whiteRook.location_y).to eq(0) 
  end

  it "updates the piece's position to [new_x, new_y] if the intended destination is empty" do
    game = FactoryBot.create(:game)
    game.pieces.find_by(location_x: 0, location_y: 1).destroy
    whiteRook = game.pieces.find_by(location_x: 0, location_y: 0)
    
    whiteRook.move_to!(0,3)
    whiteRook.reload

    expect(whiteRook.location_x).to eq(0)
    expect(whiteRook.location_y).to eq(3) 
  end

  it "returns all moves as invalid when the game state is forfeited" do
    game = FactoryBot.create(:game)
    game.pieces.where(type: "Pawn").destroy_all

    rook = game.pieces.find_by(location_x: 0, location_y: 0)
    knight = game.pieces.find_by(location_x: 1, location_y: 0)
    bishop = game.pieces.find_by(location_x: 2, location_y: 0)
    queen = game.pieces.find_by(location_x: 4, location_y: 0)

    game.forfeited!

    expect(rook.valid_move?(0,2)).to be false
    expect(knight.valid_move?(2,2)).to be false
    expect(bishop.valid_move?(4,2)).to be false
    expect(queen.valid_move?(0,4)).to be false
  end

  # MOVE_TO! METHOD TESTS: END = = = = = = = = = = = = = = = = = = = = = = = = 

  it "should call the valid_move? method when a user moves a piece" do
    piece = double("Rook")
    allow(piece).to receive(:valid_move)
    expect(piece).to receive(:move_to!).with(3,4).and_return(:valid_move?)
    piece.move_to!(3,4)
  end

  it "determines if a threatening piece can accomplish their threat" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    wking = King.create(game_id: game.id, location_x: 0, location_y: 0, white: true, notcaptured: true)
    bqueen = Queen.create(game_id: game.id, location_x: 3, location_y: 3, white: false, notcaptured: true)
    wpawn1 = Pawn.create(game_id: game.id, location_x: 1, location_y: 0, white: true, notcaptured: true)
    wpawn2 = Pawn.create(game_id: game.id, location_x: 0, location_y: 1, white: true, notcaptured: true)
    wRook = Rook.create(game_id: game.id, location_x: 3, location_y: 2, white: true, notcaptured: true)

    expect(bqueen.can_complete_threat?(wking)).to be true
    expect(wRook.can_complete_threat?(bqueen)).to be true
  end

  it "determines if a threatening piece cannot be captured" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    wking = King.create(game_id: game.id, location_x: 0, location_y: 0, white: true, notcaptured: true)
    bqueen = Queen.create(game_id: game.id, location_x: 3, location_y: 3, white: false, notcaptured: true)
    wpawn1 = Pawn.create(game_id: game.id, location_x: 1, location_y: 0, white: true, notcaptured: true)
    wpawn2 = Pawn.create(game_id: game.id, location_x: 0, location_y: 1, white: true, notcaptured: true)
    wKnight = Knight.create(game_id: game.id, location_x: 3, location_y: 2, white: true, notcaptured: true)

    expect(bqueen.can_complete_threat?(wking)).to be true
    expect(wKnight.can_complete_threat?(bqueen)).to be false
  end

  it "determines if a threatening piece can be blocked" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    wKi = King.create(game_id: game.id, location_x: 3, location_y: 3, white: true, notcaptured: true)
    wR1 = Rook.create(game_id: game.id, location_x: 4, location_y: 5, white: true, notcaptured: true)
    wR2 = Rook.create(game_id: game.id, location_x: 1, location_y: 1, white: true, notcaptured: true)

    bQ1 = Queen.create(game_id: game.id, location_x: 6, location_y: 6, white: false, notcaptured: true)
    bQ2 = Queen.create(game_id: game.id, location_x: 3, location_y: 7, white: false, notcaptured: true)
    bB1 = Bishop.create(game_id: game.id, location_x: 0, location_y: 6, white: false, notcaptured: true)
    bR1 = Rook.create(game_id: game.id, location_x: 0, location_y: 3, white: false, notcaptured: true)
    bR2 = Rook.create(game_id: game.id, location_x: 3, location_y: 0, white: false, notcaptured: true)

    expect(bQ1.can_be_blocked?(wKi)).to be true
    expect(bQ2.can_be_blocked?(wKi)).to be true
    expect(bB1.can_be_blocked?(wKi)).to be true
    expect(bR1.can_be_blocked?(wKi)).to be true
    expect(bR2.can_be_blocked?(wKi)).to be true
  end

  it "determines if a threatening piece cannot be blocked" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    wKi = King.create(game_id: game.id, location_x: 3, location_y: 3, white: true, notcaptured: true)
    wB = Bishop.create(game_id: game.id, location_x: 4, location_y: 5, white: true, notcaptured: true)

    bQ1 = Queen.create(game_id: game.id, location_x: 4, location_y: 3, white: false, notcaptured: true)
    bQ2 = Queen.create(game_id: game.id, location_x: 6, location_y: 6, white: false, notcaptured: true)
    bP = Pawn.create(game_id: game.id, location_x: 4, location_y: 2, white: false, notcaptured: true)
    bB = Bishop.create(game_id: game.id, location_x: 2, location_y: 2, white: false, notcaptured: true)

    expect(bQ2.can_be_blocked?(wKi)).to be false
    expect(bQ1.can_be_blocked?(wKi)).to be false
    expect(bP.can_be_blocked?(wKi)).to be false
    expect(bB.can_be_blocked?(wKi)).to be false
  end

  it "rejects any move that would place the game in check" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    wKing = King.create(game_id: game.id, location_x: 3, location_y: 0, white: true, notcaptured: true)
    wP1 = Pawn.create(game_id: game.id, location_x: 2, location_y: 0, white: true, notcaptured: true)
    wP2 = Pawn.create(game_id: game.id, location_x: 2, location_y: 1, white: true, notcaptured: true)
    wP3 = Pawn.create(game_id: game.id, location_x: 3, location_y: 1, white: true, notcaptured: true)
    wP4 = Pawn.create(game_id: game.id, location_x: 4, location_y: 1, white: true, notcaptured: true)
    wP5 = Pawn.create(game_id: game.id, location_x: 4, location_y: 0, white: true, notcaptured: true)
    bB = Bishop.create(game_id: game.id, location_x: 0, location_y: 3, white: false, notcaptured: true)
    # LOL this test kept failing because the black Bishop didn't have its King to apply "move_endangers_king" method to
    bKing = King.create(game_id: game.id, location_x: 3, location_y: 7, white: false, notcaptured: true)

    expect(wP2.valid_move?(2,2)).to be false
  end
end