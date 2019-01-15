require 'erb'
require 'codebreaker'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when '/' then start
    when '/rules' then
      Rack::Response.new(render('rules.html'))
    when '/game' then new_game
    when '/show_hints' then show_hints
    when '/stat' then
      Rack::Response.new(render('statistics.html'))
    else
      Rack::Response.new('Not Found', 404)
    end
  end

  def start
    Rack::Response.new(render('menu.html'))
  end

  def new_game
      #@game = Codebreaker::Game.new
     # @game.new_game
     # @game.enter_level(@request.params['level'])
      #@hints_array = @game.hints_index
      #@hints = @game.secret_code[@hints_array.shift]
      #@request.session[:game] = @game
      #@hints = @game.show_hints
     # @request.session[:game] = @game
      #@hints = @request.session[:game].show_hints
      Rack::Response.new(render('game.html'))
  end

  def show_hints
   # @game = @request.session[:game]
    #Rack::Response.new(render('menu.html'))
    #@hints = @request.session[:game].show_hints
    #@hints = @game.show_hints
  end

  def current_attempts
    #@request.session[:game].attempts
  end
  
  def current_hints
    #@request.session[:game].hints
  end

  def current_level
    #@request.params['level']
  end

  def current_secret_code
    #@request.session[:game].secret_code
  end

  def current_player
    #@request.params['player_name']
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
