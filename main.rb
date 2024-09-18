require_relative "lib/board"
require "colorize"
game = Board.new

game.display

input = gets.chomp!

while input != "exit"
  game.move_piece(input)
  break unless game.winner.nil?

  input = gets.chomp!
end

puts "#{game.winner} WINS!".colorize(:green) unless game.winner.nil?
