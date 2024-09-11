# To get a move to coordinate mapper
module MoveMapper
  def parse_coordinates(input)
    input.split.map { |pair| pair.chars.map(&:to_i) }
  end
end

class Pawn
  attr_reader :symbol
  attr_accessor :first_move, :color

  def initialize(color)
    @color = color
    @symbol = color == "black" ? "♟️" : "♟"
    @first_move = true
  end

  def move(coordinates, board = nil)
    start, pre_final = coordinates.split
    final = pre_final.chars
    final.map!(&:to_i)
    return false if !board[final[0]][final[1]].nil? && board[final[0]][final[1]].color == color

    moves = valid_moves(start)
    moves.include?(final)
  end

  private

  def valid_moves(coordinate) # rubocop:disable Metrics/AbcSize
    if @color == "black" && first_move
      @first_move = false
      [[coordinate[0].to_i + 1, coordinate[1].to_i], [coordinate[0].to_i + 2, coordinate[1].to_i]]
    elsif @color == "black"
      [[coordinate[0].to_i + 1, coordinate[1].to_i]]
    elsif @color != "black" && first_move
      @first_move = false
      [[coordinate[0].to_i - 1, coordinate[1].to_i], [coordinate[0].to_i - 2, coordinate[1].to_i]]
    else
      [[coordinate[0].to_i - 1, coordinate[1].to_i]]
    end
  end
end
