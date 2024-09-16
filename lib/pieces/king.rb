require_relative "pawn"
# I'm just fulfilling rubocop expectations tbh
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

    false
  end

  private

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
        return false if piece && piece.color == color # Blocked by own piece
        if piece
          # Check if the piece can attack vertically (i.e., a rook or queen)
          return piece.is_a?(Rook) || piece.is_a?(Queen)
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
        return false if piece && piece.color == color # Blocked by own piece
        if piece
          # Check if the piece can attack horizontally (i.e., a rook or queen)
          return piece.is_a?(Rook) || piece.is_a?(Queen)
        end

        new_col += col_step
      end
    end
    false
  end

  def check_diagonals(board) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
    # Check diagonally from the king's current position
    row, col = find_king_location(board)

    [[-1, -1], [-1, 1], [1, -1], [1, 1]].each do |row_step, col_step|
      new_row = row + row_step
      new_col = col + col_step
      while new_row.between?(0, 7) && new_col.between?(0, 7)
        piece = board[new_row][new_col]
        return false if piece && piece.color == color # Blocked by own piece
        if piece
          # Check if the piece can attack diagonally (i.e., a bishop or queen)
          return piece.is_a?(Bishop) || piece.is_a?(Queen)
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
end
