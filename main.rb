require_relative "lib/board"

game = Board.new

game.display

input = gets.chomp!

while input != "exit"
  game.move_piece(input)
  input = gets.chomp!
end
