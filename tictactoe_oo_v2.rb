require "pry"

class Board
  ROWS = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],[2,5,8],[3,6,9],[1,5,9],[3,5,7]]

  def initialize
    # Stores the plays, initially " "
    @plays = Hash.new
    (1..9).each {|i| @plays[i] = " "}
    self.draw
  end

  def [](position)
    @plays[position]
  end

  def []=(position, marker)
    @plays[position] = marker
    self.draw
  end

  def draw
    # Clear the screen
    system "clear" or system "cls"

    # Draw the board
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

  private

  def draw_line(line = [" "," "," "])
    puts "  #{line[0]}  |  #{line[1]}  |  #{line[2]}  "
  end

  def draw_separator
    puts "-----+-----+-----"
  end
end

class Mygame
  attr_reader :values, :marker

  def initialize(values, marker)
    @values = values
    @marker = marker
  end

  def <<(position)
    @values << position
  end

  def form_row?
    for row in Board::ROWS
      return true if (row - values).empty?
    end
    return false
  end

  def complete_row
    thirds_in_row = []
    for row in Board::ROWS
      if (row - values).size == 1
        thirds_in_row << (row - values).first
      end
    end
    return thirds_in_row
  end
end

class Player
  attr_reader :mygame

  def initialize(board, marker)
    @board = board
    @mygame = Mygame.new([], marker)
  end

  def add_to_board(position)
    @board[position] = @mygame.marker
    @mygame << position
    @board.draw
  end

  def form_row?
    @mygame.form_row?
  end
end

class Human < Player
  def initialize(board)
    super(board, "X")
  end

  def pick
    available_positions = @board.empty_positions
    puts "Choose a position (from 1 to 9) to place a piece:"
    begin
      choice = gets.chomp.to_i
    end until available_positions.include?(choice)
    add_to_board(choice)
  end
end

class Computer < Player
  def initialize(board)
    super(board, "O")
  end

  def pick(other_game)
    # try to complete computer's rows
    if (pos = @mygame.complete_row - other_game.values) != []
      choice = pos.first
    # try to block other player's rows
    elsif (pos = other_game.complete_row - @mygame.values) != []
      choice = pos.first
    else
    # random
      choice = @board.empty_positions.sample
    end
    add_to_board(choice)
  end
end

class Game
  def play
    board = Board.new
    human = Human.new(board)
    computer = Computer.new(board)

    loop do
      human.pick
      if human.form_row?
        puts "Congrats, you won!"
        break
      elsif board.empty_positions == []
        puts "It's a tie!"
        break
      end

      computer.pick(human.mygame)
      if computer.form_row?
        puts "Sorry, computer won!"
        break
      end
    end
  end
end

game = Game.new
game.play