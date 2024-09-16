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
    return false if board[destination[0]][destination[1]] != nil && board[destination[0]][destination[1]].color == color # rubocop:disable Style/NonNilCheck

    start_row, start_col = start
    end_row, end_col = destination

    row_diff = (end_row - start_row).abs
    col_diff = (end_col - start_col).abs

    return false unless row_diff == col_diff

    path_clear?(start, destination, board)
  end

  def possible_moves(start_pos, board)
    start_row, start_col = start_pos
    moves = []

    # Diagonal directions: top-left, top-right, bottom-left, bottom-right
    directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]]

    directions.each do |row_step, col_step|
      current_row = start_row + row_step
      current_col = start_col + col_step

      while current_row.between?(0, 7) && current_col.between?(0, 7)
        piece = board[current_row][current_col]

        if piece.nil?
          moves << [current_row, current_col]
        elsif piece.color != color
          moves << [current_row, current_col] # Can capture opponent's piece
          break
        else
          break # Blocked by own piece
        end

        current_row += row_step
        current_col += col_step
      end
    end

    moves
  end

  private

  def path_clear?(start_pos, end_pos, board)
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
end
