require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    card_values = cards.map { |e| e[1] }

    total = 0
    card_values.each do |card_value|
      if card_value == 'Ace'
        total += 1
      else
        total += card_value.to_i == 0 ? 10 : card_value.to_i
      end
    end

    card_values.select { |e| e == 'Ace' }.count.times do
      total += 10 if total + 10 <= 21
    end

    total
  end
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  # deck
  suits = ['Hearts', 'Diamonds', 'Spades', 'Clubs']
  cards = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']
  session[:deck] = suits.product(cards).shuffle!

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    @notice = "<strong>#{session[:player_name]} wins!</strong> #{session[:player_name]} hits blackjack."
  end
  erb :game
end

post '/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])

  if player_total == 21
    @notice = "<strong>#{session[:player_name]} wins!</strong> #{session[:player_name]} hits blackjack."
  elsif player_total > 21
    @error = "<strong>#{session[:player_name]} loses!</strong> It looks like #{session[:player_name]} busted at #{player_total}."
  end

  erb :game
end

post '/stay' do
  @dealer_turn = true
  while calculate_total(session[:dealer_cards]) < 17
    session[:dealer_cards] << session[:deck].pop
  end

  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])

  if dealer_total == player_total
    @notice = "<strong>It's a tie!</strong> Both #{session[:player_name]} and the dealer stayed at #{player_total}."
  elsif dealer_total == 21
    @error = "<strong>#{session[:player_name]} loses!</strong> The dealer hits blackjack!"
  elsif dealer_total > 21
    @notice = "<strong>#{session[:player_name]} wins!</strong> The dealer busted at #{dealer_total}. #{session[:player_name]} stayed at #{player_total}."
  elsif dealer_total < 21 && dealer_total > player_total
    @error = "<strong>#{session[:player_name]} loses!</strong> #{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}."
  elsif dealer_total < 21 && dealer_total < player_total
    @notice = "<strong>#{session[:player_name]} wins!</strong> #{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}."
  end

  erb :game
end

get '/game_over' do
  session[:player_name] = nil
  redirect '/new_player'
end

