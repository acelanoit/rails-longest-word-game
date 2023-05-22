# frozen_string_literal: true

# New game and score logic
class GamesController < ApplicationController
  def new
    @initial_time = Time.now
    vowel_array = %w[A E I O U].sample(2)
    letters_array = ('A'..'Z').to_a.sample(8)
    final_array = vowel_array + letters_array
    @grid = final_array.join(' ')
  end

  def score
    require 'open-uri'
    # Check if word is valid
    @time = (Time.now - params[:time].to_datetime).round
    @word = params[:word]
    @grid = params[:grid]
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    api_data_serialized = URI.open(url).read
    result_hash = JSON.parse(api_data_serialized)
    word_valid = result_hash['found']
    # Check if all letters are valid
    letters_valid = @word.chars.none? { |letter| !@grid.include?(letter.upcase) }
    # Check if letters are overused
    letters_overused = false
    @word.chars.each do |letter|
      letters_overused = true unless @word.count(letter) <= @grid.count(letter.upcase)
    end
    @score = 0
    if !word_valid
      @message = "You lost: #{@word} is not an english word"
    elsif !letters_valid
      @message = 'You lost: one or more of the letters you used are not in the grid'
    elsif letters_overused
      @message = 'You lost: you used the same letter too many times (not in the grid)'
    else
      @score = @word.length - (@time * 0.2)
      @message = 'Well done!'
    end
  end
end
