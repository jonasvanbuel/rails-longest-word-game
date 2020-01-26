require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.shuffle[0, 10]
  end

  def score
    # Grab params and set instance variables
    @attempt_array = params[:attempt].downcase.split('')
    @letters_array = params[:letters].downcase.split('')
    @timestamp_load = Time.parse(params[:timestamp_load])
    @timestamp_submit = Time.now
    @valid = true

    # Step 1 - is the word only using letters given?
    # Count and compare the number of occurances of the letter in both attempt
    # and letters
    @valid = @attempt_array.all? do |letter|
      @attempt_array.count(letter) == @letters_array.count(letter)
    end

    # Step 2 - is the word a proper English word?
    # Define endpoint
    endpoint = "https://wagon-dictionary.herokuapp.com/#{@attempt_array.join}"
    # Return serialized string
    api_serialized = open(endpoint).read
    # Parse serialized string to hash
    api_hash = JSON.parse(api_serialized)
    # Set '@valid' to true / false
    @valid = api_hash["found"]

    # Step 3 - set word length
    @length = api_hash["length"]

    # Step 4 - get time passed between page loading and submit
    @seconds = @timestamp_submit - @timestamp_load

    # Step 5 - generate score based on above paramaters
    if @valid
      @score = @length / @letters_array.length.to_f

      @tmp_time_score = @seconds / 60

      @score = @score / @tmp_time_score
      # raise
    else
      @score = 0
    end

    # REDIRECT???
  end
end
