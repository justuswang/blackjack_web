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
end

get '/' do
  if session[:player_name]
    redirect 'game'
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
  suits = ['Heart', 'Diamond', 'Spade', 'Club']
  cards = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(cards).shuffle!

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  erb :game
end

