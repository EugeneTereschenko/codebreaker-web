# frozen_string_literal: true

RSpec.describe Racker do
  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:game) { Codebreaker::Game.new }
  let(:easy) { 'easy' }
  let(:test) { 'Test' }

  context 'rules path' do
    before { get '/rules' }

    it { expect(last_response).to be_ok }
    it { expect(last_response.body).to include Codebreaker::Game.message(:rules_test) }
  end

  context 'unknown path' do
    before { get '/unknown' }

    it { expect(last_response).to be_not_found }
    it { expect(last_response.body).to include Codebreaker::Game.message(:not_found) }
  end

  context 'statistics path' do
    before { get '/stat' }

    it { expect(last_response).to be_ok }
    it { expect(last_response.body).to include Codebreaker::Game.message(:codebreak_year) }
    it { expect(last_response.body).to include Codebreaker::Game.message(:top_of_player) }
    it { expect(last_response.body).to include Codebreaker::Game.message(:level_stat) }
    it { expect(last_response.body).to include Codebreaker::Game.message(:attempt_stat) }  
    it { expect(last_response.body).to include 'Test' }
    it { expect(last_response.body).to include '6/24' }
    it { expect(last_response.body).to include '3/0' }
  end

  context 'game' do
    it 'makes number' do
      post '/game', number: '1234', level: 'easy', player_name: 'Test'
      expect(last_response.body).to include last_request.params['player_name']
    end
  end

  context 'submit_answer' do
    it 'sub answer' do
      game.new_game
      game.enter_level(easy)
      game.enter_name(test)
      env 'rack.session', game: game
      post '/submit_answer', number: game.secret_code.join
      expect(last_response.body).to include Codebreaker::Game.message(:won, name: 'Test')
    end
  end

  context 'root path' do
    before { get '/' }

    it { expect(last_response).to be_ok }
    it { expect(last_response.body).to include Codebreaker::Game.message(:codebreak_year) }
    it { expect(last_response.body).to include Codebreaker::Game.message(:guess_number) }
  end

  context 'win' do
    it 'win' do
      game.new_game
      game.enter_level(easy)
      game.enter_name(test)
      env 'rack.session', game: game
      get '/win'
      expect(last_response).to be_ok
      expect(last_response.body).to include Codebreaker::Game.message(:won, name: 'Test')
    end
  end

  context 'lose' do
    it 'lose' do
      game.new_game
      game.enter_level(easy)
      game.enter_name(test)
      env 'rack.session', game: game
      get '/lose'
      expect(last_response).to be_ok
      expect(last_response.body).to include Codebreaker::Game.message(:name_lose, name: 'Test')
    end
  end
end
