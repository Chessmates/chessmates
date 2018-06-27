require 'rails_helper'

RSpec.describe Game, type: :model do
  it "will not be valid with an empty name" do
    game = FactoryBot.build(:game, game_name: "")

    expect(game).not_to be_valid
  end

  it "will not be valid with a name less than 3 characters" do
    game = FactoryBot.build(:game, game_name: "Bo")

    expect(game).not_to be_valid
  end

  it "will generate all chess pieces when created" do
    game = FactoryBot.create(:game)

    whiteRookLeft = game.pieces_by_col_then_row[0][0]
    blackRookRight = game.pieces_by_col_then_row[7][7]

    expect(whiteRookLeft.white).to be true
    expect(whiteRookLeft.type).to eq("Rook")

    expect(blackRookRight.white).to be false
    expect(blackRookRight.type).to eq("Rook")

    expect(game.pieces.count).to eq(32)
    expect(game.pieces.where(white: true).count).to eq(16)
    expect(game.pieces.where(white: false).count).to eq(16)
  end

  it "will have a status of 'active' when created" do
    game = FactoryBot.create(:game)

    expect(game.active?).to be true
  end

  it "is forfeitable when it has two players" do
    black_player = FactoryBot.create(:white_player)
    game = FactoryBot.create(:game, { black_player_id: black_player.id })

    expect(game.forfeitable?).to be true
  end
  ### CHECKMATE TESTS ###
  it "should be in check" do
    setup_game_and_king
    setup_check
    expect(@game.checkmate?(@black_king.white)).to be true
  end

  private
  def setup_game_and_king
    black_player = FactoryBot.create(:white_player)
    @game = FactoryBot.create(:game, { black_player_id: black_player.id })
    @black_king = @game.pieces.find_by(type:'King', white:false)
  end

  def setup_check
    setup_game_and_king
    @white_pawn = @game.pieces.find_by(type:'Pawn', white:true, location_x: 4)
    @white_pawn.update_attributes(location_y: 2, has_moved: true)
    @white_pawn.reload
    @black_pawn = @game.pieces.find_by(type:'Pawn', white:false, location_x: 5)
    @black_pawn.update_attributes(location_y: 6, has_moved: true)
    @black_pawn.reload
    @white_queen = @game.pieces.find_by(type:'Queen', white:true)
    @white_queen.update_attributes(location_x: 7, location_y: 4, has_moved: true)
    @white_queen.reload
  end

end
