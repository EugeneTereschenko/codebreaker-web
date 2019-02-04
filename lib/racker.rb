require 'erb'
require 'codebreaker'

class Racker

  attr_reader :game, :arr_hints
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @arr_hints = []
  end

  def response
    case @request.path
    when '/' then start
    when '/rules' then
      Rack::Response.new(render('rules.html'))
    when '/game' then new_game
    when '/show_hints' then show_hints
    when '/stat' then  stat
    when '/submit_answer' then submit_answer
    when '/win' then win
    when '/lose' then lose
    else
      Rack::Response.new('Not Found', 404)
    end
  end

  def stat
    @stat = Codebreaker::Statistics.new
    @data_stat = @stat.stats
    Rack::Response.new(render('statistics.html'))
  end

  def start
    Rack::Response.new(render('menu.html'))
  end

  def new_game
      @game = Codebreaker::Game.new
      @game.new_game
      @game.enter_level(@request.params['level'])
      @game.enter_name(@request.params['player_name'])
      @game.save 
      #@hints_array = @game.hints_index
      #@hints = @game.secret_code[@hints_array.shift]
      @request.session[:game] = @game
      #@hints = @game.show_hints
      #@request.session[:game] = @game
      #@hints = @request.session[:game].show_hints
      Rack::Response.new(render('game.html'))
  end

  def destroy_session
    @request.session.clear
  end

  def win
    Rack::Response.new(render('win.html')) do
      destroy_session
    end
  end

  def lose
    Rack::Response.new(render('lose.html')) do
      destroy_session
    end
  end

  def submit_answer
    puts @request.session[:game]
    @request.session[:game].handle_guess(@request.params['number'])
    @request.session[:game_result] = @request.session[:game].game_result
    puts @request.session[:game].secret_code

    return win if @request.session[:game].equal_codes?(@request.params['number'])
    return lose unless @request.session[:game].attempts.positive?
    Rack::Response.new(render('game.html'))
  end

  def show_hints
    #@game = @request.session[:game]
    #Rack::Response.new(render('menu.html'))
    @hints = @request.session[:game].show_hints
    @arr_hints.push(@hints)
    @show_hints_array = @arr_hints.join(', ')
    Rack::Response.new(render('game.html'))
  end

  def current_attempts
    @request.session[:game].attempts
  end
  
  def current_hints
    @request.session[:game].hints
  end

  def current_level
    @request.session[:game].level
  end

  def current_secret_code
    @request.session[:game].secret_code
  end

  def current_player
    @request.session[:game].name
  end

  def render(template)
    path = File.expand_path("../views/#{template}",
      __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def word
    @request.cookies['word'] || 'Nothing'
  end

end
