require 'rails_helper'

RSpec.describe PiecesController, type: :controller do

  describe "update#pieces action" do

    it "shouldn't allow unauthenticated users to update piece's position" do
      whitepiece = FactoryBot.create(:piece, location_x: 0, location_y: 1)

      patch :update, params: { game_id: whitepiece.game_id, id: whitepiece.id, piece: { location_x: 0, location_y: 2 } }
      expect(response).to redirect_to new_user_session_path

      whitepiece.reload
      expect(whitepiece.location_x).to eq(0)
      expect(whitepiece.location_y).to eq(1)
    end

    it "should allow only game players update a piece's position" do
      whitepiece = FactoryBot.create(:piece, location_x: 0, location_y: 1)
      user_not_player = FactoryBot.create(:white_player)
      sign_in user_not_player

      patch :update, params: { game_id: whitepiece.game_id, id: whitepiece.id, piece: { location_x: 0, location_y: 2 } }
      expect(response).to have_http_status(:forbidden)

      whitepiece.reload
      expect(whitepiece.location_x).to eq(0)
      expect(whitepiece.location_y).to eq(1)
    end

    it "should allow only white player update a white piece's position" do
      whitepiece = FactoryBot.create(:piece, location_x: 0, location_y: 1)
      bplayer = FactoryBot.create(:white_player)
      sign_in bplayer

      patch :update, params: { game_id: whitepiece.game_id, id: whitepiece.id, piece: { location_x: 0, location_y: 2 } }
      expect(response).to have_http_status(:forbidden)

      whitepiece.reload
      expect(whitepiece.location_x).to eq(0)
      expect(whitepiece.location_y).to eq(1)
    end

    it "should allow only black player update a black piece's position" do
      bplayer = FactoryBot.create(:white_player)
      game = FactoryBot.create(:game, black_player_id: bplayer.id)
      blackpiece = Piece.find_by(location_x: 0, location_y: 6)
      sign_in game.white_player

      patch :update, params: { game_id: blackpiece.game_id, id: blackpiece.id, piece: { location_x: 0, location_y: 5 } }
      expect(response).to have_http_status(:forbidden)

      blackpiece.reload
      expect(blackpiece.location_x).to eq(0)
      expect(blackpiece.location_y).to eq(6)
    end

    it "should update the piece's position" do
      whitepiece = FactoryBot.create(:piece, location_x: 0, location_y: 0)
      sign_in whitepiece.game.white_player

      patch :update, params: { game_id: whitepiece.game_id, id: whitepiece.id, piece: { location_x: 0, location_y: 2 } }
      expect(response).to have_http_status(:no_content) # There is no template rendered after the #update action

      whitepiece.reload
      expect(whitepiece.location_x).to eq(0)
      expect(whitepiece.location_y).to eq(2)
    end

    it "should return a NotFound(404) error if the piece was not found" do
      whitepiece = FactoryBot.create(:piece, location_x: 0, location_y: 0)
      sign_in whitepiece.game.white_player

      patch :update, params: { game_id: whitepiece.game_id, id: 'BOOBOO', piece: { location_x: 0, location_y: 2 } }
      expect(response).to have_http_status(:not_found)

      whitepiece.reload
      expect(whitepiece.location_x).to eq(0)
      expect(whitepiece.location_y).to eq(0)
    end

    it "should update the has_moved boolean from false to true when a piece is first moved" do
      game = FactoryBot.create(:game)
      sign_in game.white_player
      pawn = game.pieces.find_by(location_x: 0, location_y: 1)

      expect(pawn.has_moved).to be false

      patch :update, params: { game_id: game.id, id: pawn.id, piece: { location_x: 0, location_y: 2, has_moved: true } }
      pawn.reload

      expect(pawn.has_moved).to be true
    end

    it "should return a Forbidden(403) error if the piece's move is invalid" do
      game = FactoryBot.create(:game)
      game.pieces.find_by(location_x: 1, location_y: 1).destroy
      whiteRook = game.pieces.find_by(location_x: 0, location_y: 0)
      sign_in whiteRook.game.white_player

      patch :update, params: { game_id: game.id, id: whiteRook.id, piece: { location_x: 2, location_y: 2, has_moved: true } }

      expect(response).to have_http_status(:forbidden)
    end

    # it "should return a Forbidden(403) error if the piece's move places its King in check" do
    #   game = FactoryBot.create(:game)
    #   game.pieces.destroy_all

    #   wKi = King.create(game_id: game.id, location_x: 3, location_y: 0, white: true, notcaptured: true)
    #   wP1 = Pawn.create(game_id: game.id, location_x: 2, location_y: 0, white: true, notcaptured: true)
    #   wP2 = Pawn.create(game_id: game.id, location_x: 2, location_y: 1, white: true, notcaptured: true)
    #   wP3 = Pawn.create(game_id: game.id, location_x: 3, location_y: 1, white: true, notcaptured: true)
    #   wP4 = Pawn.create(game_id: game.id, location_x: 4, location_y: 1, white: true, notcaptured: true)
    #   wP5 = Pawn.create(game_id: game.id, location_x: 4, location_y: 0, white: true, notcaptured: true)
    #   bB = Bishop.create(game_id: game.id, location_x: 0, location_y: 3, white: false, notcaptured: true)

    #   sign_in game.white_player

    #   patch :update, params: { game_id: game.id, id: wP2.id, piece: { location_x: 2, location_y: 2, has_moved: true } }

    #   puts response.body
      # expect(response).to have_http_status(:forbidden)
    end
  end
end
