require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    card_values = cards.map { |e| e[1] }

    total = 0
    card_values.each do |card_value|
      if card_value == 'A'
        total += 1
      else
        total += card_value.to_i == 0 ? 10 : card_value.to_i
      end
    end

    card_values.select { |e| e == 'A' }.count.times do
      total += 10 if total + 10 <= 21
    end

    total
  end

  def card_image(card)
    suit = case card[0]
    when 'H' then 'hearts'
    when 'D' then 'diamonds'
    when 'C' then 'clubs'
    when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end
end

before do
  @show_hit_or_stay_buttons = true
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
  session[:player_name] = params[:player_name].empty? ? "Guest" : params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:turn] = session[:player_name]
  # deck
  suits = ['H', 'D', 'S', 'C']
  cards = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
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
    @success = "<strong>#{session[:player_name]} wins!</strong> #{session[:player_name]} hits blackjack."
    @show_hit_or_stay_buttons = false
  end
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])

  if player_total == 21
    @success = "<strong>#{session[:player_name]} wins!</strong> #{session[:player_name]} hits blackjack."
    @show_hit_or_stay_buttons = false
  elsif player_total > 21
    @error = "<strong>#{session[:player_name]} loses!</strong> It looks like #{session[:player_name]} busted at #{player_total}."
    @show_hit_or_stay_buttons = false
  end

  erb :game
end

post '/game/player/stay' do
  @show_hit_or_stay_buttons = false

  session[:turn] = 'dealer'
  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == 21
    @error = "<strong>#{session[:player_name]} loses!</strong> The dealer hits blackjack!"
  elsif dealer_total > 21
    @success = "<strong>#{session[:player_name]} wins!</strong> The dealer busted at #{dealer_total}."
  elsif dealer_total >= 17
    redirect '/game/compare'
  elsif
    @show_dealer_hit_button = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false
  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])

  if dealer_total > player_total
    @error = "<strong>#{session[:player_name]} loses!</strong> #{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}."
  elsif dealer_total < 21 && dealer_total < player_total
    @success = "<strong>#{session[:player_name]} wins!</strong> #{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}."
  else
    @info = "<strong>It's a tie!</strong> Both #{session[:player_name]} and the dealer stayed at #{player_total}."
  end

  erb :game
end

get '/game_over' do
  session[:player_name] = nil
  redirect '/new_player'
end

