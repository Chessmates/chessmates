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
end
