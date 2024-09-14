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

  def check?(board = nil)
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
end
