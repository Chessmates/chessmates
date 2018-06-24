FactoryBot.define do

  factory :piece do
    location_x {rand(0..7)}
    location_y {rand(0..7)}
    white :true
    association :game
  end

  factory :king do
    
  end

  factory :queen do
    
  end
  
  factory :rook do
    
  end
  
  factory :bishop do
    
  end
  
  factory :knight do
    
  end
  
  factory :pawn do
    
  end

  factory :white_player, class: User do
    sequence :username do |u|
      "username#{u}"
    end
    sequence :email do |n|
      "dummyEmail2#{n}@gmail.com"
    end
    password "secretPassword"
    password_confirmation "secretPassword"
  end

  factory :game do
    sequence :game_name do |a|
      "Game#{a}"
    end
    state :active
    association :white_player
  end
end