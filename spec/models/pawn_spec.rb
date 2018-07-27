require 'rails_helper'

RSpec.describe Pawn, type: :model do
  it "should allow white pawns to move forward vertically 1 place at a time" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 1, white: true, has_moved: false, notcaptured: true)
    
    expect(piece1.valid_move?(0,2)).to be true
  end

   it "should allow black pawns to move forward vertically 1 place at a time" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 6, white: false, has_moved: false, notcaptured: true)
    
    expect(piece1.valid_move?(0,5)).to be true
   end

   it "shouldn't allow white pawns to move forward vertically more than 1 place at a time, except on first move" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 1, white: true, has_moved: false, notcaptured: true)

    expect(piece1.valid_move?(0,3)).to be true

    piece1.move_to!(0,3)
    piece1.reload

    expect(piece1.valid_move?(0,5)).to be false
   end

   it "shouldn't allow black pawns to move forward vertically more than 1 place at a time, except on first move" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 6, white: false, has_moved: false, notcaptured: true)

    expect(piece1.valid_move?(0,4)).to be true

    piece1.move_to!(0,4)
    piece1.reload

    expect(piece1.valid_move?(0,2)).to be false
   end

   it "shouldn't allow backward moves for a white pawn" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 1, white: true, has_moved: false, notcaptured: true)

    expect(piece1.valid_move?(0,0)).to be false
   end

   it "shouldn't allow backward moves for a black pawn" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 6, white: false, has_moved: false, notcaptured: true)

    expect(piece1.valid_move?(0,7)).to be false
   end

   it "should allow a diagonal move for white pawn if it's a capture_move" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 1, white: true, has_moved: false, notcaptured: true)
    piece2 = Pawn.create(game_id: game.id, location_x: 1, location_y: 2, white: false, has_moved: false, notcaptured: true)

    expect(piece1.valid_move?(1,2)).to be true
   end

   it "should allow a diagonal move for black pawn if it's a capture_move" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 6, white: false, has_moved: false, notcaptured: true)
    piece2 = Pawn.create(game_id: game.id, location_x: 1, location_y: 5, white: true, has_moved: false, notcaptured: true)

    expect(piece1.valid_move?(1,5)).to be true
   end

   it "shouldn't allow a diagonal move if it isn't a capture_move" do
    game = FactoryBot.create(:game)
    piece1 = Pawn.create(game_id: game.id, location_x: 0, location_y: 1, white: true, has_moved: false, notcaptured: true)
    piece2 = Pawn.create(game_id: game.id, location_x: 6, location_y: 6, white: false, has_moved: false, notcaptured: true)

    expect(piece1.valid_move?(1,2)).to be false
    expect(piece2.valid_move?(1,5)).to be false
   end


end
