require "pry"

class Board
  ROWS = [[1,2,3],[4,5,6],[7,8,9],[1,4,7],[2,5,8],[3,6,9],[1,5,9],[3,5,7]]

  def initialize
    # Stores the data, initially " "
    @data = Hash.new
    (1..9).each {|i| @data[i] = " "}
    self.draw
  end

  def [](position)
    @data[position]
  end

  def []=(position, marker)
    @data[position] = marker
    self.draw
  end

  def draw
    # Clear the screen
    system "clear" or system "cls"

    # Draw the board
    draw_line
    draw_line([@data[1],@data[2],@data[3]])
    draw_line
    draw_separator
    draw_line
    draw_line([@data[4],@data[5],@data[6]])
    draw_line
    draw_separator
    draw_line
    draw_line([@data[7],@data[8],@data[9]])
    draw_line
  end

  def empty_positions
    @data.select {|k,v| v == " "}.keys
  end

  def occupied_positions
    @data.select {|k,v| v != " "}.keys
  end

  def full?
    empty_positions == []
  end

  private

  def draw_line(line = [" "," "," "])
    puts "  #{line[0]}  |  #{line[1]}  |  #{line[2]}  "
  end

  def draw_separator
    puts "-----+-----+-----"
  end
end

class Game
  attr_reader :positions

  def initialize
    @positions = []
  end

  def <<(position)
    @positions << position
  end

  def form_row?
    for row in Board::ROWS
      return true if (row - positions).empty?
    end
    return false
  end

  def complete_row
    thirds_in_row = []
    for row in Board::ROWS
      if (row - positions).size == 1
        thirds_in_row << (row - positions).first
      end
    end
    return thirds_in_row
  end
end

class Player
  attr_reader :game

  def initialize(board, marker)
    @board = board
    @marker = marker
    @game = Game.new
  end

  def add_to_board(position)
    @board[position] = @marker
    @game << position
    @board.draw
  end
end

class Human < Player
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
  def pick(other_game)
    # try to complete computer's rows
    if (pos = @game.complete_row - @board.occupied_positions) != []
      choice = pos.first
    # try to block other player's rows
    elsif (pos = other_game.complete_row - @board.occupied_positions) != []
      choice = pos.first
    else
    # random
      choice = @board.empty_positions.sample
    end
    add_to_board(choice)
  end
end

class GamePlay
  def play
    board = Board.new
    human = Human.new(board, "X")
    computer = Computer.new(board, "O")

    loop do
      human.pick
      if human.game.form_row?
        puts "Congrats, you won!"
        break
      elsif board.full?
        puts "It's a tie!"
        break
      end

      computer.pick(human.game)
      if computer.game.form_row?
        puts "Sorry, computer won!"
        break
      end
    end
  end
end

GamePlay.new.play