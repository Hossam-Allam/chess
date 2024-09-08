# Board class that is responsible for populating and printing the board
class Board
  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8) }
  end

  def display # rubocop:disable Metrics/MethodLength
    @board.each_with_index do |row, i|
      2.times do # Make each box two rows tall
        row.each_with_index do |cell, j|
          if (i + j).even?
            print "\e[41m     \e[0m"  # Red background, four spaces for width
          else
            print "\e[40m     \e[0m"  # Black background, four spaces for width
          end
        end
        puts # Move to the next line after printing a row
      end
    end
  end
end
