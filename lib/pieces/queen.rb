require_relative "pawn"
# I'm just fulfilling rubocop expectations tbh
class Queen
  include MoveMapper
  attr_reader :symbol, :color

  def initialize(color)
    @color = color
    @symbol = color == "black" ? "♕" : "♛"
  end

  def move(coordinates, board) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    start, destination = parse_coordinates(coordinates)
    return false if board[destination[0]][destination[1]] != nil && board[destination[0]][destination[1]].color == color # rubocop:disable Style/NonNilCheck

    if is_diagonal?(start, destination)
      is_diagonal_path_clear?(start, destination, board)
    elsif start[0] == destination[0]
      col_move_verifier(start, destination, board)
    elsif start[1] == destination[1]
      row_move_verifier(start, destination, board)
    else
      false
    end
  end

  private

  def is_diagonal?(start, destination)
    start_row, start_col = start
    end_row, end_col = destination

    row_diff = (end_row - start_row).abs
    col_diff = (end_col - start_col).abs

    row_diff == col_diff
  end

  def is_diagonal_path_clear?(start_pos, end_pos, board)
    start_row, start_col = start_pos
    end_row, end_col = end_pos
    return false if end_row < 0 || end_row > 7 || end_col < 0 || end_col > 7

    # determining the direction
    row_step = end_row > start_row ? 1 : -1
    col_step = end_col > start_col ? 1 : -1

    current_row = start_row + row_step
    current_col = start_col + col_step

    while current_row != end_row && current_col != end_col
      return false unless board[current_row][current_col].nil?

      current_row += row_step
      current_col += col_step
    end

    true
  end

  def row_move_verifier(start, destination, board) # rubocop:disable Metrics/MethodLength
    start_row = start[0]
    end_col = destination[1]
    end_row = destination[0]
    return false if end_row < 0 || end_row > 7

    step = start_row < end_row ? 1 : -1
    current_row = start_row + step
    while current_row != end_row
      return false unless board[current_row][end_col].nil?

      current_row += step
    end

    true
  end

  def col_move_verifier(start, destination, board) # rubocop:disable Metrics/MethodLength
    start_col = start[1]
    end_row = destination[0]
    end_col = destination[1]
    return false if end_col < 0 || end_col > 7

    step = start_col < end_col ? 1 : -1
    current_col = start_col + step
    while current_col != end_col
      return false unless board[end_row][current_col].nil?

      current_col += step
    end

    true
  end
end
