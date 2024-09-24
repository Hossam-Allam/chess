require_relative "lib/board"
require "colorize"

game = Board.new

game.display
puts "Type 'help' for a game guide or type 'exit' to exit the game"

input = gets.chomp!
def help
  puts "Hello, and welcome to my chess game".colorize(:blue)
  puts "You're probably about how you should play the game\nWell it's simple"
  puts "You should enter the current row and column of the piece and then after a space the row and column of the destination"
  puts "For example, if you want to move the leftmost white pawn you would type: '60 50'and it will move forwards once"
  puts "All chess rules are applied as normal in this game, with the abscense of threefold repitition and en passant (both can be added later)"
  puts "Castling notation is 'o-o' for king side and 'o-o-o' for queen side"
  puts "For pawn upgrades you will be prompted to enter the piece you wish to recieve"
  puts "That's it! I hope you enjoy the game".colorize(:green)
end

while input != "exit"
  if input.downcase == "help"
    help

  else
    game.move_piece(input)
    break unless game.winner.nil?

  end
  input = gets.chomp!
end

if game.winner == "tie"
  puts "Game ends in a tie"
else
  puts "#{game.winner} WINS!".colorize(:green) unless game.winner.nil?
end
