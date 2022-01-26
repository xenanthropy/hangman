# frozen-string-literal: true

require 'json'

# Main game class
class Hangman
  attr_accessor :data, :hangman_string

  def initialize(wrong_guesses, guessed_letters, word, progress)
    self.data = { wrong_guesses: wrong_guesses, guessed_letters: guessed_letters, word: word, progress: progress }
    self.hangman_string = " _________ \n"\
                          " |/      ⠀ \n"\
                          " |       ⠀ \n"\
                          " |      ⠀⠀⠀\n"\
                          " |      ⠀ ⠀\n"\
                          " |         \n"\
                          " |         \n"\
                          "_|___      \n"
    create_progress(word, guessed_letters)
  end

  # Main method of the program
  # Prints the relevant game info then takes input and checks to see whether 
  # you are taking a guess, or saving your game
  def start_round
    print_info
    check_win
    if data[:wrong_guesses] < 7
      puts 'Pick a letter, or type "save" to save your game and quit'
      input = gets.chomp
      while (input.length > 1 && input != 'save') || data[:guessed_letters].include?(input.downcase)
        puts 'Not a valid input! (Pick a letter you have not chosen, or type "save")'
        input = gets.chomp
      end
      save_game(self) if input.downcase == 'save'
      data[:guessed_letters] += input.downcase
      send_guess(input.downcase)
      start_round
    else
      end_game
    end
  end

  # Prints the relevant info for showing your progress
  def print_info
    puts hangman_string
    puts ''
    puts data[:progress]
    puts ''
    puts "Guessed letters: #{data[:guessed_letters].split('').join(' ')}"
    puts ''
  end

  # Upon initialization of the Hangman class instance, replaces all of the selected word's
  # characters with underscores (and pads between with spaces). When run in the program, compares the word
  # with your guessed characters to replace underscores with the correctly guessed letter/s
  def create_progress(word, guessed_letters)
    word_with_spaces = word.strip.split('').join(' ').split('')
    puts "guessed letters: #{data[:guessed_letters]}"
    if guessed_letters.length.positive?
      word_with_spaces.each_with_index do |char, index|
        word_with_spaces[index] = '_' if !guessed_letters.include?(char) && char != ' '
      end
      word_with_spaces = word_with_spaces.join('')
    else
      word_with_spaces = word_with_spaces.join('')
      word.split('').each { |character| word_with_spaces.gsub!(character, '_') }
    end
    data[:progress] = word_with_spaces
  end

  # Adds on to the hangman depending on how many wrong guesses you have made
  def edit_hangman(wrong_guesses)
    case wrong_guesses
    when 1
      self.hangman_string = hangman_string.sub('⠀', '|')
    when 2
      self.hangman_string = hangman_string.sub('⠀', 'O')
    when 3
      self.hangman_string = hangman_string.sub('⠀', '/')
    when 4
      self.hangman_string = hangman_string.sub('⠀', '|')
    when 5
      self.hangman_string = hangman_string.sub('⠀', '\\')
    when 6
      self.hangman_string = hangman_string.sub('⠀', '/')
    when 7
      self.hangman_string = hangman_string.sub('⠀', '\\')
    end
  end

  # Saves the game to 'savefile.sav' and ends the program
  def save_game(class_instance)
    puts 'Saving game... please wait'
    sleep(3)
    serialized_object = Marshal.dump(class_instance)
    File.write('savefile.sav', serialized_object)
    puts 'Game saved! Goodbye'
    sleep(2)
    exit
  end

  # Checks to see if the word contains your letter guess
  def send_guess(input)
    if data[:word].include?(input)
      create_progress(data[:word], data[:guessed_letters])
    else
      data[:wrong_guesses] += 1
      edit_hangman(data[:wrong_guesses])
    end
  end

  # Ends program if you run out of guesses
  def end_game
    puts "Sorry! You lost. The word was #{data[:word]}."
  end

  # Checks to see if all letters have been guessed
  def check_win
    condensed = data[:progress].gsub(' ', '')
    return unless condensed == data[:word]

    puts "Congratulations! #{data[:word]} was the word. You win!"
    exit
  end
end

# Starting class that gives the choice of starting new game or continuing from save
class StartGame
  def begin
    puts "Do you want to start a new game or continue from a save file?\n1. New Game\n2. Continue"
    input = gets.chomp
    while input != '1' && input != '2'
      puts 'Please select either 1 or 2'
      input = gets.chomp
    end
    while input == '2' && !File.exist?('savefile.sav')
      puts 'Sorry, no save file was detected! Please start a new game.'
      puts "Do you want to start a new game or continue from a save file?\n1. New Game\n2. Continue"
      input = gets.chomp
    end
    game = if input == '1'
             Hangman.new(0, '', WordSelector.random_word, '')
           else
             Marshal.load(File.read('savefile.sav'))
           end
    game.start_round
  end
end

# Reads in dictionary file, then selects a random word
class WordSelector
  def self.random_word
    dict = File.readlines('5desk.txt')
    word = ''
    word = dict.sample.strip.downcase while word.length < 5 || word.length > 12
    word
  end
end

start = StartGame.new
start.begin
