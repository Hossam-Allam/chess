require_relative "pawn"

class Bishop # rubocop:disable Style/Documentation
  include MoveMapper
  attr_reader :symbol, :color

  def initialize(color)
    @color = color
    @symbol = color == "black" ? "♗" : "♝"
  end

  def move(coordinates, board)
    start, destination = parse_coordinates(coordinates)
    start_row, start_col = start
    end_row, end_col = destination

    row_diff = (end_row - start_row).abs
    col_diff = (end_col - start_col).abs

    return false unless row_diff == col_diff

    path_clear?(start, destination, board)
  end

  private

  def path_clear?(start_pos, end_pos, board)
    start_row, start_col = start_pos
    end_row, end_col = end_pos

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
end
