require_relative "pieces/pawn"
require_relative "escape_sequences"
require_relative "pieces/rook"
require_relative "pieces/knight"
# Board class that is responsible for populating and printing the board
class Board
  include EscapeSequences

  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8, " ") }
    place_pawns
    place_rooks
    place_knights
  end

  def place_pawns
    @board[1].map! { |col| Pawn.new("black").symbol }
    @board[6] = Array.new(8) { Pawn.new("white").symbol }
  end

  def place_rooks
    @board[0][0] = Rook.new("white").symbol
    @board[0][7] = Rook.new("white").symbol

    @board[7][0] = Rook.new("black").symbol
    @board[7][7] = Rook.new("black").symbol
  end

  def place_knights
    @board[0][1] = Knight.new("white").symbol
    @board[0][6] = Knight.new("white").symbol

    @board[7][1] = Knight.new("black").symbol
    @board[7][6] = Knight.new("black").symbol
  end

  def display # rubocop:disable Metrics/MethodLength
    @board.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        # First row of the 2x2 box, print the piece symbol
        if (i + j).even?
          print "\e[41m #{cell}  \e[0m"  # Red background with piece symbol
        else
          print "\e[40m #{cell}  \e[0m"  # Black background with piece symbol
        end
      end
      puts
      row.each_with_index do |cell, j|
        # Second row of the 2x2 box, print empty spaces
        if (i + j).even?
          print "\e[41m    \e[0m"  # Red background
        else
          print "\e[40m    \e[0m"  # Black background
        end
      end
      puts
    end
  end
end
