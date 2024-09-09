class King
  attr_reader :symbol

  def initialize(color)
    @symbol = color == "black" ? "♚" : "♔"
  end
end
