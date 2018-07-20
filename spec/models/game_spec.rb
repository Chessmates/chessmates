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

  it "identifies defending kings (white or black)" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    wKing = King.create(game_id: game.id, location_x: 3, location_y: 0, white: true)
    bKing = King.create(game_id: game.id, location_x: 3, location_y: 7, white: false)

    expect(game.defending_king(true).type).to eq "King"
    expect(game.defending_king(true).location_y).to eq 0
    expect(game.defending_king(false).type).to eq "King"
    expect(game.defending_king(false).location_y).to eq 7
  end

  it "identifies a threatening piece" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    king = King.create(game_id: game.id, location_x: 3, location_y: 0, white: true, notcaptured: true)
    wqueen = Queen.create(game_id: game.id, location_x: 2, location_y: 1, white: true, notcaptured: true)
    bqueen = Queen.create(game_id: game.id, location_x: 3, location_y: 3, white: false, notcaptured: true)

    expect(game.threatning_piece(king).present?).to be true
    puts game.endangers_king?(true)
  end

  it "determines if the game is in check or not" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    king = King.create(game_id: game.id, location_x: 3, location_y: 0, white: true, notcaptured: true)
    wqueen = Queen.create(game_id: game.id, location_x: 2, location_y: 1, white: true, notcaptured: true)
    bqueen = Queen.create(game_id: game.id, location_x: 3, location_y: 3, white: false, notcaptured: true)

    expect(game.check?(true)).to be true

    wqueen.move_to!(3,1)
    wqueen.reload

    expect(game.check?(true)).to be false
  end

  it "determines if a game is in checkmate" do
    game = FactoryBot.create(:game)
    game.pieces.destroy_all

    king = King.create(game_id: game.id, location_x: 3, location_y: 0, white: true, notcaptured: true)
    wpawn1 = Pawn.create(game_id: game.id, location_x: 2, location_y: 1, white: true, notcaptured: true)
    bqueen = Queen.create(game_id: game.id, location_x: 3, location_y: 3, white: false, notcaptured: true)
    wpawn2 = Pawn.create(game_id: game.id, location_x: 2, location_y: 0, white: true, notcaptured: true)
    wpawn3 = Pawn.create(game_id: game.id, location_x: 4, location_y: 0, white: true, notcaptured: true)
    wpawn4 = Pawn.create(game_id: game.id, location_x: 4, location_y: 1, white: true, notcaptured: true)

    expect(game.checkmate?(true)).to be true
  end
end
