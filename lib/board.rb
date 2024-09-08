require_relative "pawn"
require_relative "escape_sequences"
# Board class that is responsible for populating and printing the board
class Board
  include EscapeSequences

  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8, " ") }
    place_pawns
  end

  def place_pawns
    @board[1] = Array.new(8) { Pawn.new("black").symbol }
    @board[6] = Array.new(8) { Pawn.new("white").symbol }
  end

  def display
    hide_cursor  # Hide the cursor for a cleaner display
    puts_clear   # Clear any previous output

    # Print the board with row and column labels
    8.times do |i|
      m = 7 - i
      print "#{m + 1} " # Print row labels
      @board[i].each_with_index do |cell, j|
        if (i + j).even?
          print "\e[41m #{cell}  \e[0m"  # Red background with piece symbol
        else
          print "\e[40m #{cell}  \e[0m"  # Black background with piece symbol
        end
      end
      puts
    end

    # Print column labels
    print "  "
    8.times do |i|
      print "  #{(i + 97).chr} " # Print column labels (a-h)
    end
    puts

    show_cursor # Show the cursor again after printing the board
  end
end
