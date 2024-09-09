class Rook
  attr_accessor :symbol

  def initialize(color)
    @symbol = color == "black" ? "♜" : "♖"
  end
end
