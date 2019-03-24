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
      Rack::Response.new(render('rules.html.erb'))
    when '/game' then new_game
    when '/show_hints' then show_hints
    when '/stat' then  stat
    when '/submit_answer' then submit_answer
    when '/win' then win
    when '/lose' then lose
    else
      Rack::Response.new(I18n.t('not_found'), 404)
    end
  end

  def stat
    @stat = Codebreaker::Statistics.new('./data/stat.yml')
    @data_stat = @stat.stats
    Rack::Response.new(render('statistics.html.erb'))
  end

  def start
    return Rack::Response.new(render('game.html.erb')) if @request.session.key?(:game)

    Rack::Response.new(render('menu.html.erb'))
  end

  def new_game
    @game = Codebreaker::Game.new
    @game.new_game
    @game.enter_level(@request.params['level'])
    @game.enter_name(@request.params['player_name'])
    @request.session[:game] = @game
    @request.session[:array_hints] = []
    @request.session[:used_attempts] = @request.session[:game].attempts
    @request.session[:used_hints] = @request.session[:game].hints
    Rack::Response.new(render('game.html.erb'))
  end

  def destroy_session
    @request.session.clear
  end

  def win
    @request.session[:game].save('./data/stat.yml')
    Rack::Response.new(render('win.html.erb')) do
      destroy_session
    end
  end

  def lose
    Rack::Response.new(render('lose.html.erb')) do
      destroy_session
    end
  end

  def submit_answer
    @request.session[:game].handle_guess(@request.params['number'])
    @request.session[:number] = @request.params['number']
    @request.session[:game_result] = @request.session[:game].game_result

    return win if @request.session[:game].equal_codes?(@request.params['number'])
    return lose unless @request.session[:game].attempts.positive?

    Rack::Response.new(render('game.html.erb'))
  end

  def show_hints
    @request.session[:game].take_hints
    @hints = @request.session[:game].show_hints
    @request.session[:array_hints].push(@hints)
    Rack::Response.new(render('game.html.erb'))
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
