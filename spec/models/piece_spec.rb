require 'rails_helper'

RSpec.describe Piece, type: :model do
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

  it "determines that a piece's path is invalid for this method" do
    game = FactoryBot.create(:game)
    piece1 = Piece.create(location_x: 1, location_y: 3, game_id: game.id)
    piece1.save!
    piece2 = Piece.create(location_x: 2, location_y: 4, game_id: game.id)
    piece2.save!

    expect(piece1.is_obstructed?(3,6)).to eq("ERROR: Invalid Piece Path")
  end


  it "captures the opponent's piece on the intended destination, then assumes that position" do
    game = FactoryBot.create(:game)
    whiteRook = game.pieces.find_by(location_x:0, location_y: 0)
    dest = game.pieces.find_by(location_x: 7, location_y: 7) # this is blackRook

    whiteRook.move_to!(7,7)
    dest.reload
   
    expect(dest.notcaptured).to be false
    expect(whiteRook.location_x).to eq(7)
    expect(whiteRook.location_y).to eq(7) 
  end

  it "generates an error message if a piece's destination is occupied by a friendly" do
    game = FactoryBot.create(:game)
    whiteRook = game.pieces.find_by(location_x:0, location_y: 0)
    dest = game.pieces.find_by(location_x: 7, location_y: 1)

    whiteRook.move_to!(7,1)

    expect(whiteRook.move_to!(7,1)).to eq("ERROR! Cannot move there; occupied by a friendly piece")
    expect(dest.notcaptured).to be true
    expect(whiteRook.location_x).to eq(0)
    expect(whiteRook.location_y).to eq(0) 
  end

  it "updates the piece's position to [new_x, new_y] if the intended destination is empty" do
    game = FactoryBot.create(:game)
    whiteRook = game.pieces.find_by(location_x:0, location_y: 0)
    dest = game.pieces.find_by(location_x: 3, location_y: 3)
    
    whiteRook.move_to!(3,3)

    expect(dest).to be_nil
    expect(whiteRook.location_x).to eq(3)
    expect(whiteRook.location_y).to eq(3) 
  end
end