require 'rails_helper'

RSpec.describe Bishop, type: :model do
  let(:game) { create(:game) }
  describe "moving" do
    context "valid moves" do
      it "validates moves" do
        bishop_game = create(:game)
        bishop_game.pieces.destroy_all

        lpawn = Pawn.create(x_position: 1, y_position: 2, game_id: bishop_game.id)
        rpawn = Pawn.create(x_position: 3, y_position: 2, game_id: bishop_game.id)
        bishop = Bishop.create(x_position: 2, y_position: 0, game_id: bishop_game.id)
        expect(bishop.valid_move?(3, 1)).to be true
        expect(bishop.valid_move?(1, 1)).to be true
        expect(bishop.valid_move?(4, 2)).to be true
        bishop.update_attributes(x_position: 4, y_position: 2)
        expect(bishop.valid_move?(2, 4)).to be true
        bishop.update_attributes(x_position: 2, y_position: 4)
        expect(bishop.valid_move?(0, 6)).to be true
        expect(bishop.valid_move?(0, 2)).to be true
        bishop.update_attributes(x_position: 0, y_position: 2)
        expect(bishop.valid_move?(2, 0)).to be true
        bishop.update_attributes(x_position: 2, y_position: 0)
      end
    end
    context "invalid moves" do
      it "invalidates moves" do
        bishop_game = create(:game)
        bishop = bishop_game.bishops.where(x_position: 2, y_position: 0).first

        expect(bishop.valid_move?(1, 0)).to be false
        expect(bishop.valid_move?(3, 0)).to be false
        expect(bishop.valid_move?(2, 1)).to be false

        bishop.update_attributes(y_position: 4)

        expect(bishop.valid_move?(2, 2)).to be false
        expect(bishop.valid_move?(4, 4)).to be false
        expect(bishop.valid_move?(2, 6)).to be false

        expect(bishop.valid_move?(-1, 1)).to be false

        expect(bishop.valid_move?(3, 1)).to be false
      end
    end
  end
end
