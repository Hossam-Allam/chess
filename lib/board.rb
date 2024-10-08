require_relative "pieces/pawn"
require_relative "escape_sequences"
require_relative "pieces/rook"
require_relative "pieces/knight"
require_relative "pieces/bishop"
require_relative "pieces/king"
require_relative "pieces/queen"
# Board class that is responsible for keeping track of the board, it is the engine of this chess game
class Board
  include EscapeSequences
  include MoveMapper

  attr_accessor :board, :turn, :white_king, :black_king, :is_check, :winner

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
    @turn = 0
    @is_check = false
    @winner = nil
    place_pawns
    place_rooks
    place_knights
    place_bishops
    place_kings
    place_queens
    @white_king = @board[7][4]
    @black_king = @board[0][4]
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
    # hide_cursor
    puts_clear
    column_labels = "   0   1   2   3   4   5   6   7" # Column labels

    @board.each_with_index do |row, i|
      print "#{i} " # Print the row number on the left side
      row.each_with_index do |cell, j|
        piece_symbol = cell.nil? ? " " : cell.symbol # Use symbol from object or default
        if (i + j).even?
          print "\e[41m #{piece_symbol}  \e[0m"  # Red background with piece symbol
        else
          print "\e[40m #{piece_symbol}  \e[0m"  # Black background with piece symbol
        end
      end
      puts
      print "  " # Offset for row coloring
      row.each_with_index do |_cell, j|
        if (i + j).even?
          print "\e[41m    \e[0m"  # Red background
        else
          print "\e[40m    \e[0m"  # Black background
        end
      end
      puts
    end

    puts column_labels # Print the bottom row of column numbers
  end

  def whose_turn
    turn.even? ? "white" : "black"
  end

  def move_piece(move) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    if ["O-O", "O-O-O"].include?(move.chomp.upcase)
      castle = move.chomp.upcase

      if castle(castle)
        puts "successful castling"
        @turn += 1
        display
      else
        puts "Invalid castling"
      end

      return
    end

    unless move.match?(/^\d{2} \d{2}$/)
      puts "Invalid input format"
      return
    end

    coordinates = parse_coordinates(move)
    color = whose_turn
    piece = @board[coordinates[0][0]][coordinates[0][1]]
    if color == "white"
      my_king = @white_king
      other_king = @black_king
    else
      my_king = @black_king
      other_king = @white_king
    end
    # Check if the piece is nil, if the color doesn't match, or if the move is invalid
    if piece.nil? || piece.color != color || !piece.move(move, @board)
      puts "Invalid move"
      return
    end

    original_piece = @board[coordinates[1][0]][coordinates[1][1]] # Save piece at destination (if any)
    @board[coordinates[1][0]][coordinates[1][1]] = piece
    @board[coordinates[0][0]][coordinates[0][1]] = nil

    # Check if this move puts the current player's king in check
    if my_king.check?(@board)
      # If the move puts own king in check, revert the move
      @board[coordinates[0][0]][coordinates[0][1]] = piece
      @board[coordinates[1][0]][coordinates[1][1]] = original_piece
      puts "Move puts your own king in check. Invalid move."
      return
    end
    puts coordinates[0][0]
    puts piece.class
    pawn_upgrade(coordinates, color) if ((coordinates[1][0]).zero? || coordinates[1][0] == 7) && piece.is_a?(Pawn)
    # @board[coordinates[1][0]][coordinates[1][1]] = piece
    potential_king = @board[coordinates[1][0]][coordinates[1][1]]
    if potential_king.instance_of?(King)
      if potential_king.color == "white"
        @white_king = potential_king
        @white_king.location = [coordinates[1][0], coordinates[1][1]]
        @white_king.is_first_move = false
      else
        @black_king = potential_king
        @black_king.location = [coordinates[1][0], coordinates[1][1]]
        @black_king.is_first_move = false
      end
    end

    if other_king.check?(@board)
      @is_check = true
      if other_king.checkmate?(@board)
        puts "#{color} checkmates the opponent's king"
        @winner = color
      else
        puts "#{color} put the opponent's king in check!"
      end

    elsif other_king.tie?(@board)
      @winner = "tie"
    else
      @is_check = false
    end

    @turn += 1
    display
  end

  def pawn_upgrade(coordinates, color) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    puts "Your pawn has reached the end of the board, please enter you wish to have"
    valid = false
    until valid
      piece = gets.chomp.downcase

      case piece
      when "knight"
        @board[coordinates[1][0]][coordinates[1][1]] = Knight.new(color)
        valid = true
      when "bishop"
        @board[coordinates[1][0]][coordinates[1][1]] = Bishop.new(color)
        valid = true
      when "queen"
        @board[coordinates[1][0]][coordinates[1][1]] = Queen.new(color)
        valid = true
      when "rook"
        @board[coordinates[1][0]][coordinates[1][1]] = Rook.new(color)
        valid = true
      else
        puts "incorrect input, please choose between: knight, bishop, queen, rook"
      end
    end
  end

  def castle(move)
    king = whose_turn == "white" ? @white_king : @black_king
    row = whose_turn == "white" ? 7 : 0
    king_col = 4
    rook_col = move == "O-O" ? 7 : 0
    new_king_col = move == "O-O" ? 6 : 2
    new_rook_col = move == "O-O" ? 5 : 3

    # Check if castling is allowed: king and rook haven't moved, no pieces in between, not in check
    return false unless king.is_first_move && @board[row][rook_col].is_a?(Rook) && @board[row][rook_col].is_first_move
    return false unless path_clear_for_castling?(row, king_col, rook_col)
    return false if king.check?(@board) || king_would_be_in_check?(king, row, king_col, new_king_col)

    # Move king and rook
    @board[row][new_king_col] = king
    @board[row][new_rook_col] = @board[row][rook_col]
    @board[row][king_col] = nil
    @board[row][rook_col] = nil

    # Update king and rook positions
    king.location = [row, new_king_col]
    @board[row][new_rook_col].is_first_move = false
    king.is_first_move = false

    true
  end

  def path_clear_for_castling?(row, king_col, rook_col)
    range = king_col < rook_col ? (king_col + 1...rook_col) : (rook_col + 1...king_col)
    range.all? { |col| @board[row][col].nil? }
  end

  def king_would_be_in_check?(king, row, king_col, new_king_col)
    return true if king.check?(@board)

    # Simulate each intermediate position
    (king_col..new_king_col).each do |col|
      temp_board = @board.dup
      temp_board[row][col] = king
      return true if king.check?(temp_board)
    end

    false
  end
end
