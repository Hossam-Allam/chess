require_relative "pieces/pawn"
require_relative "escape_sequences"
require_relative "pieces/rook"
require_relative "pieces/knight"
require_relative "pieces/bishop"
require_relative "pieces/king"
require_relative "pieces/queen"
# Board class that is responsible for populating and printing the board
class Board
  include EscapeSequences
  include MoveMapper

  attr_accessor :board, :turn

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
    @turn = 0
    place_pawns
    place_rooks
    place_knights
    place_bishops
    place_kings
    place_queens
  end

  def place_pawns
    @board[1].map! { |_| Pawn.new("black") }
    @board[6].map! { |_| Pawn.new("white") }
  end

  def place_rooks
    @board[0][0] = Rook.new("black")
    @board[0][7] = Rook.new("black")
    @board[7][0] = Rook.new("white")
    @board[7][7] = Rook.new("white")
  end

  def place_knights
    @board[0][1] = Knight.new("black")
    @board[0][6] = Knight.new("black")
    @board[7][1] = Knight.new("white")
    @board[7][6] = Knight.new("white")
  end

  def place_bishops
    @board[0][2] = Bishop.new("black")
    @board[0][5] = Bishop.new("black")
    @board[7][2] = Bishop.new("white")
    @board[7][5] = Bishop.new("white")
  end

  def place_kings
    @board[0][4] = King.new("black")
    @board[7][4] = King.new("white")
  end

  def place_queens
    @board[0][3] = Queen.new("black")
    @board[7][3] = Queen.new("white")
  end

  def display
    hide_cursor
    puts_clear
    @board.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        piece_symbol = cell.nil? ? " " : cell.symbol # Use symbol from object or default
        if (i + j).even?
          print "\e[41m #{piece_symbol}  \e[0m"  # Red background with piece symbol
        else
          print "\e[40m #{piece_symbol}  \e[0m"  # Black background with piece symbol
        end
      end
      puts
      row.each_with_index do |_cell, j|
        if (i + j).even?
          print "\e[41m    \e[0m"  # Red background
        else
          print "\e[40m    \e[0m"  # Black background
        end
      end
      puts
    end
  end

  def whose_turn
    turn.even? ? "white" : "black"
  end

  def move_piece(move) # rubocop:disable Metrics/AbcSize
    coordinates = parse_coordinates(move)
    color = whose_turn

    piece = @board[coordinates[0][0]][coordinates[0][1]]

    # Check if the piece is nil, if the color doesn't match, or if the move is invalid
    if piece.nil? || piece.color != color || !piece.move(move, @board)
      puts "Invalid move"
      return
    end

    # Move the piece if everything is valid
    @board[coordinates[1][0]][coordinates[1][1]] = piece
    @board[coordinates[0][0]][coordinates[0][1]] = nil
    @turn += 1
    display
  end
end
