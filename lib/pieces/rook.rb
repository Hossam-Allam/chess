require_relative "pawn"
# Rook class
class Rook
  include MoveMapper
  attr_accessor :symbol, :color

  def initialize(color)
    @color = color
    @symbol = color == "black" ? "♖" : "♜"
  end

  def move(coordinates, board)
    start, destination = parse_coordinates(coordinates)
    return false if !board[destination[0]][destination[1]].nil? && board[destination[0]][destination[1]].color == color

    if start[0] == destination[0]
      col_move_verifier(start, destination, board)
    elsif start[1] == destination[1]
      row_move_verifier(start, destination, board)
    else
      false
    end
  end

  def possible_moves(start_pos, board)
    moves = []
    moves.concat(horizontal_vertical_moves(start_pos, board))
    moves
  end

  private

  def row_move_verifier(start, destination, board)
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

  def col_move_verifier(start, destination, board)
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

  def horizontal_vertical_moves(start_pos, board)
    start_row, start_col = start_pos
    moves = []

    # Directions: up, down, left, right
    directions = [[-1, 0], [1, 0], [0, -1], [0, 1]]

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
end
