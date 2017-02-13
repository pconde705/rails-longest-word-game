require 'open-uri'
require 'json'
require 'net/http'

class WordController < ApplicationController
  def game
    @nine_grid = generate_grid(9)
  end

  def score
    @try = params["name"]
    grid = params["grid"].chars
    time_end = Time.now
    time_start = params["timer"]
    time_parsed = Time.parse(time_start)
    @final = run_game(@try, grid, time_parsed, time_end)
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    range_array = ("A".."Z").to_a
    return Array.new(grid_size) { range_array.sample }
  end

  def check_grid?(attempt, grid)
    attempt.chars.all? { |letter| attempt.chars.count(letter) <= grid.count(letter) } # chars split only on characters
  end


  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    uri = URI("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=cade3e18-8167-4360-8726-f816f832da6c&input=#{attempt}")
    result_uri = Net::HTTP.get(uri)
    json_parse = JSON.parse(result_uri)
    result = {}
    attempt.upcase!

    time_calc = end_time - start_time

    translation = json_parse["outputs"][0]["output"]

    message = ""
    score = 0

    if attempt == translation.upcase
      score = 0
      message = "not an english word"
      translation = nil
    elsif attempt.length <= 5
      score += 3 + (25 - time_calc)
      message = "well done"
    elsif attempt.length <= 7
      score += 5 + (50 - time_calc)
      message = "Fantastic"
    end

    unless check_grid?(attempt, grid)
      message = "not in the grid"
      score = 0
    end

    result[:message] = message
    result[:score] = score
    result[:translation] = translation
    result[:time] = time_calc

    return result
  end


end
