require_relative "pawn"
# King class, responsible for checking check, checkmate, and tie situations (along with king movement)
class King
  include MoveMapper
  attr_reader :symbol, :color
  attr_accessor :location

  def initialize(color)
    @color = color
    @symbol = color == "black" ? "♔" : "♚"
    @location = color == "black" ? [0, 4] : [7, 4]
  end

  def move(coordinates, board)
    start, destination = parse_coordinates(coordinates)
    return false if board[destination[0]][destination[1]] && board[destination[0]][destination[1]].color == color

    if valid_king_move?(start, destination)
      path_clear?(start, destination, board)
    else
      false
    end
  end

  def check?(board)
    return true if check_vertical(board)
    return true if check_horizontal(board)
    return true if check_diagonals(board)
    return true if check_knights(board)
    return true if check_pawns(board)

    false
  end

  def checkmate?(board)
    # 1. Check if the king can escape by moving to any adjacent square

    return false if king_can_escape?(board)

    # 2. Check if any other piece can block the check or capture the attacking piece
    return false if block_or_capture_possible?(board)

    # If neither the king can escape nor another piece can block the check, it's checkmate
    true
  end

  def tie?(board)
    return false if check?(board)
    return false if any_piece_can_move?(board)
    return false if king_can_move?(board)

    true
  end

  private

  def any_piece_can_move?(board) # rubocop:disable Metrics/MethodLength
    player_pieces = find_pieces_of_color(color, board)

    player_pieces.each do |piece, row, col|
      next if piece.is_a?(King)

      possible_moves = piece.possible_moves([row, col], board)
      possible_moves.each do |move|
        move_coordinates = "#{row}#{col} #{move.join}" # The move method expects a string

        if piece.move(move_coordinates, board) && !is_piece_pinned?(move_coordinates, board)
          return true # If any valid move is found, return true
        end
      end
    end
    false # If no valid move is found, return false
  end

  def is_piece_pinned?(move, board)
    raise "Board is nil" if board.nil? # Early error detection for a nil board

    coordinates = parse_coordinates(move)
    piece = board[coordinates[0][0]][coordinates[0][1]]
    original_piece = board[coordinates[1][0]][coordinates[1][1]] # Save piece at destination (if any)

    # Simulate the move
    board[coordinates[1][0]][coordinates[1][1]] = piece
    board[coordinates[0][0]][coordinates[0][1]] = nil

    king_is_in_check = check?(board) # Assuming check? checks if the king of 'color' is in check

    # Revert the move
    board[coordinates[0][0]][coordinates[0][1]] = piece
    board[coordinates[1][0]][coordinates[1][1]] = original_piece

    king_is_in_check # Return true if the move results in a check (piece is pinned)
  end

  def king_can_move?(board)
    row, col = find_king_location(board)
    possible_moves = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]

    possible_moves.each do |row_step, col_step|
      new_row = row + row_step
      new_col = col + col_step
      next unless new_row.between?(0, 7) && new_col.between?(0, 7)

      piece_at_new_pos = board[new_row][new_col]
      return true if (piece_at_new_pos.nil? || piece_at_new_pos.color != color) && safe_move?(new_row, new_col, board)
    end
    false
  end

  def valid_king_move?(start, destination)
    row_diff = (destination[0] - start[0]).abs
    col_diff = (destination[1] - start[1]).abs

    row_diff <= 1 && col_diff <= 1 # King moves one square in any direction
  end

  def path_clear?(_start, destination, board)
    board[destination[0]][destination[1]].nil? || board[destination[0]][destination[1]].color != color
  end

  def find_king_location(board)
    board.each_with_index do |row, row_index|
      row.each_with_index do |piece, col_index|
        return [row_index, col_index] if piece.is_a?(King) && piece.color == color
      end
    end
    nil
  end

  def check_vertical(board)
    # Check up and down from the king's current position
    row, col = find_king_location(board)

    [-1, 1].each do |row_step|
      new_row = row + row_step
      while new_row.between?(0, 7)
        piece = board[new_row][col]

        if piece

          break if piece.color == color

          # Check if the piece can attack vertically (i.e., a rook or queen)
          break unless piece.is_a?(Rook) || piece.is_a?(Queen)

          return true
        end

        new_row += row_step
      end
    end
    false
  end

  def check_horizontal(board)
    # Check left and right from the king's current position
    row, col = find_king_location(board)

    [-1, 1].each do |col_step|
      new_col = col + col_step
      while new_col.between?(0, 7)
        piece = board[row][new_col]

        if piece

          break if piece.color == color

          # Check if the piece can attack horizontally (i.e., a rook or queen)
          break unless piece.is_a?(Rook) || piece.is_a?(Queen)

          return true
        end

        new_col += col_step
      end
    end
    false
  end

  def check_diagonals(board)
    row, col = find_king_location(board)

    # Iterate over all diagonal directions
    [[-1, -1], [-1, 1], [1, -1], [1, 1]].each do |row_step, col_step|
      new_row = row + row_step
      new_col = col + col_step

      # Check each square along the diagonal
      while new_row.between?(0, 7) && new_col.between?(0, 7)
        piece = board[new_row][new_col]

        if piece

          # Blocked by own piece
          break if piece.color == color

          break unless piece.is_a?(Bishop) || piece.is_a?(Queen)

          return true

        end

        new_row += row_step
        new_col += col_step
      end
    end

    false
  end

  def check_knights(board)
    # Check the knight's movement range from the king's current position
    row, col = find_king_location(board)

    knight_moves = [[-2, -1], [-2, 1], [2, -1], [2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2]]
    knight_moves.each do |row_step, col_step|
      new_row = row + row_step
      new_col = col + col_step
      next unless new_row.between?(0, 7) && new_col.between?(0, 7)

      piece = board[new_row][new_col]
      # Check if the piece is an opponent's knight
      return true if piece && piece.is_a?(Knight) && piece.color != color
    end
    false
  end

  def check_pawns(board)
    # Find the king's current position
    row, col = find_king_location(board)

    # Define pawn attack directions based on the color of the king
    pawn_moves = color == :white ? [[-1, -1], [-1, 1]] : [[1, -1], [1, 1]]

    # Check if an opponent's pawn is threatening the king
    pawn_moves.each do |row_step, col_step|
      new_row = row + row_step
      new_col = col + col_step

      next unless new_row.between?(0, 7) && new_col.between?(0, 7)

      piece = board[new_row][new_col]

      # Check if the piece is an opponent's pawn
      return true if piece && piece.is_a?(Pawn) && piece.color != color
    end

    false
  end

  def king_can_escape?(board)
    row, col = find_king_location(board)

    # Possible directions the king can move
    moves = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]

    moves.each do |row_step, col_step|
      new_row = row + row_step
      new_col = col + col_step
      next unless new_row.between?(0, 7) && new_col.between?(0, 7) # Move must stay on the board

      # Simulate moving the king to the new location
      if safe_move?(new_row, new_col, board)
        return true # King can escape to this square
      end
    end
    false
  end

  def safe_move?(new_row, new_col, board)
    king_location = find_king_location(board) # Store the king's current location
    # return false unless king_location # Return false if the king is not found

    original_piece = board[new_row][new_col]
    unless original_piece.nil? || original_piece.color == color
      board[new_row][new_col] = board[king_location[0]][king_location[1]] # Move king to the new location
      board[king_location[0]][king_location[1]] = nil # Clear old king position

      safe = !check?(board) # Check if the new position is safe (not in check)

      # Undo the move (restore the board state)
      board[king_location[0]][king_location[1]] = board[new_row][new_col] # Restore the king to its original position
      board[new_row][new_col] = original_piece # Restore the original piece in the new position
    end
    safe
  end

  def block_or_capture_possible?(board)
    player_pieces = find_pieces_of_color(color, board) # Find all pieces of the king's color

    player_pieces.each do |piece, row, col|
      next if piece.is_a?(King)

      possible_moves = piece.possible_moves([row, col], board)

      possible_moves.each do |move|
        if safe_after_move?(piece, row, col, move, board)
          return true # A piece can block or capture the attacking piece
        end
      end
    end
    false
  end

  def safe_after_move?(piece, start_row, start_col, destination, board)
    original_piece = board[destination[0]][destination[1]]
    board[destination[0]][destination[1]] = piece
    board[start_row][start_col] = nil

    safe = !check?(board) # Check if the king is still in check after the move

    # Undo the move (restore the board state)
    board[start_row][start_col] = piece
    board[destination[0]][destination[1]] = original_piece

    safe
  end

  def find_pieces_of_color(color, board)
    pieces = []
    board.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        pieces << [piece, row_idx, col_idx] if piece && piece.color == color
      end
    end
    pieces
  end
end
