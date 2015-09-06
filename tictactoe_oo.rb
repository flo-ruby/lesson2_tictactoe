require "pry"

class Grid
  ROWS = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],[2,5,8],[3,6,9],[1,5,9],[3,5,7]]

  def initialize
    # Stores the plays, initially " "
    @plays = Hash.new
    (1..9).each {|i| @plays[i] = " "}
    self.draw
  end

  def draw
    # Clear the screen
    system "clear" or system "cls"

    # Draw the grid
    draw_line
    draw_line([@plays[1],@plays[2],@plays[3]])
    draw_line
    draw_separator
    draw_line
    draw_line([@plays[4],@plays[5],@plays[6]])
    draw_line
    draw_separator
    draw_line
    draw_line([@plays[7],@plays[8],@plays[9]])
    draw_line
  end

  def empty_positions
    @plays.select {|k,v| v == " "}.keys
  end

  def add(position, mark)
    @plays[position] = mark
    self.draw
  end

  def three_in_row?(mark)
    for row in ROWS
      return mark if @plays[row[0]] == mark && @plays[row[1]] == mark && @plays[row[2]] == mark
    end
    return false
  end

# if two marks in a row and last one still available, return the position to complete row
  def third_in_row_of_two(mark)
    for row in ROWS
      a = [@plays[row[0]] == mark, @plays[row[1]] == mark, @plays[row[2]] == mark]
      if a.count(true) == 2
        third_in_row = row[a.index(false)]
        return third_in_row if @plays[third_in_row] == " "
      end
    end
    return false
  end

  private

  def draw_line(line = [" "," "," "])
    puts "  #{line[0]}  |  #{line[1]}  |  #{line[2]}  "
  end

  def draw_separator
    puts "-----+-----+-----"
  end

end

class Player
  def initialize(grid, mark)
    @grid = grid
    @mark = mark
  end
end

class Human < Player
  def pick
    available_positions = @grid.empty_positions
    puts "Choose a position (from 1 to 9) to place a piece:"
    begin
      choice = gets.chomp.to_i
    end until available_positions.include?(choice)
    @grid.add(choice, @mark)
  end
end

class Computer < Player
  def pick
    if pos = @grid.third_in_row_of_two("O")
      choice = pos
    elsif pos = @grid.third_in_row_of_two("X")
      choice = pos
    else
      choice = @grid.empty_positions.sample
    end
    @grid.add(choice, @mark)
  end
end

class Game
  def initialize
  end

  def play
    @grid = Grid.new
    @human = Human.new(@grid, "X")
    @computer = Computer.new(@grid, "O")

    loop do
      @human.pick
      if @grid.three_in_row?("X")
        puts "Congrats, you won!"
        break
      elsif @grid.empty_positions == []
        puts "It's a tie!"
        break
      end

      @computer.pick
      if @grid.three_in_row?("O")
        puts "Sorry, computer won!"
        break
      end
    end
  end
end

game = Game.new
game.play