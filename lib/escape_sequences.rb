module EscapeSequences
  def move_up(n)
    print "\e[#{n}A"
  end

  def move_down(n)
    print "\e[#{n}B"
  end

  def move_forward(n)
    print "\e[#{n}C"
  end

  def move_backward(n)
    print "\e[#{n}D"
  end

  def puts_clear
    puts "\e[0J"
  end

  def hide_cursor
    print "\e[?25l"
  end

  def show_cursor
    print "\e[?25h"
  end
end
