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

  def move(coordinates, board)
    pre_start, pre_final = coordinates.split
    start = pre_start.chars
    start.map!(&:to_i)
    final = pre_final.chars
    final.map!(&:to_i)
    return false if !board[final[0]][final[1]].nil? && board[final[0]][final[1]].color == color

    moves = valid_moves(start, board)
    moves.include?(final)
  end

  def possible_moves(start_pos, board)
    moves = []
    moves.concat(valid_moves(start_pos, board))
    moves
  end

  private

  def valid_moves(coordinate, board)
    row, col = coordinate
    moves = []

    direction = color == "black" ? 1 : -1

    # Normal move (one square forward)
    moves << [row + direction, col] if board[row + direction][col].nil?

    # First move (can move two squares forward if path is clear)
    if first_move && board[row + direction][col].nil? && board[row + (direction * 2)][col].nil?
      moves << [row + (direction * 2), col]
    end

    # Diagonal captures (can only capture opponent's pieces)
    [-1, 1].each do |diagonal|
      new_col = col + diagonal
      next unless new_col.between?(0, 7)

      piece = board[row + direction][new_col]
      moves << [row + direction, new_col] if piece && piece.color != color
    end

    moves
  end
end
