require_relative "pawn"
# Knight class
class Knight
  include MoveMapper
  attr_reader :symbol, :color

  def initialize(color)
    @color = color
    @symbol = color == "black" ? "♘" : "♞"
  end

  def move(coordinates, _board)
    start, destination = parse_coordinates(coordinates)
    return false if !board[destination[0]][destination[1]].nil? && board[destination[0]][destination[1]].color == color

    possible_moves = filter_valid_moves(knight_moves(start))

    possible_moves.include?(destination)
  end

  private

  def knight_moves(position)
    moves = [
      [2, 1], [2, -1], [-2, 1], [-2, -1],
      [1, 2], [1, -2], [-1, 2], [-1, -2]
    ]

    x, y = position

    moves.map do |dx, dy|
      [x + dx, y + dy]
    end
  end

  def filter_valid_moves(moves)
    valid_range = (0..7)

    moves.select do |x, y|
      valid_range.include?(x) && valid_range.include?(y)
    end
  end
end
