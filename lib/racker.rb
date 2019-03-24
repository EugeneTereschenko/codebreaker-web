# frozen_string_literal: true

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
      render_response('rules.html.erb')
    when '/game' then new_game
    when '/show_hints' then show_hints
    when '/stat' then  stat
    when '/submit_answer' then submit_answer
    when '/win' then win
    when '/lose' then lose
    else
      render_response('notfound.html.erb')
    end
  end

  def stat
    @stat = Codebreaker::Statistics.new('./data/stat.yml')
    @data_stat = @stat.stats
    render_response('statistics.html.erb')
  end

  def start
    return render_response('game.html.erb') if @request.session.key?(:game)

    render_response('menu.html.erb')
  end

  def new_game
    @game = Codebreaker::Game.new
    @game.new_game
    @game.enter_level(@request.params['level'])
    @game.enter_name(@request.params['player_name'])
    @request.session[:game] = @game
    @request.session[:array_hints] = []
    render_response('game.html.erb')
  end

  def destroy_session
    @request.session.clear
  end

  def win
    @request.session[:game].save('./data/stat.yml')
    render_response('win.html.erb') do
      destroy_session
    end
  end

  def lose
    render_response('lose.html.erb') do
      destroy_session
    end
  end

  def submit_answer
    @request.session[:game].handle_guess(@request.params['number'])
    @request.session[:number] = @request.params['number']
    @request.session[:game_result] = @request.session[:game].game_result

    return win if @request.session[:game].equal_codes?(@request.params['number'])
    return lose unless @request.session[:game].attempts.positive?

    render_response('game.html.erb')
  end

  def show_hints
    @request.session[:game].take_hints
    @hints = @request.session[:game].show_hints
    @request.session[:array_hints].push(@hints)
    render_response('game.html.erb')
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def render_response(template)
    Rack::Response.new(render(template))
  end
end
