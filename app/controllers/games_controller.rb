require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    session[:score] ||= 0
  end

  def score
    @letters = params[:letters].split(" ")
    @word = params[:word].upcase

    if valid_word?(@word, @letters) && french_word?(@word)
      @result = "Félicitations ! #{@word} est un mot valide en anglais."
      @score = @word.length
    elsif !valid_word?(@word, @letters)
      @result = "Désolé, mais #{@word} ne peut pas être formé à partir de #{@letters.join(", ")}."
      @score = 0
    else
      @result = "Désolé, mais #{@word} n'est pas un mot valide en anglais."
      @score = 0
    end

    session[:score] += @score
    @total_score = session[:score]
  end

  private

  def valid_word?(word, letters)
    word.chars.all? { |letter| letters.count(letter) >= word.count(letter) }
  end

  def french_word?(word)
    url = "https://api.dictionaryapi.dev/api/v2/entries/en/#{word}"
    response = URI.open(url).read
    json = JSON.parse(response)
    !json.is_a?(Hash)
  rescue OpenURI::HTTPError
    false
  end
end
