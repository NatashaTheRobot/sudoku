# Shovel board into $boards
# Do work to $boards[-1]
# return puzzle if work results in complete puzzle
# if work does not result in complete puzzle, do
#   find the first cell with 2+ possible values, delete that value from its possible values
#   duplicate the board and assign that cell's value to the deleted value.
#   shovel that board into $boards
# (since this is recursive, it will create a new board each time it finds a situation in which the board is incomplete and it has to make guesses)

#

module SudokuSolver

  ROWS =       [0, 0, 0, 0, 0, 0, 0, 0, 0,
                1, 1, 1, 1, 1, 1, 1, 1, 1,
                2, 2, 2, 2, 2, 2, 2, 2, 2,
                3, 3, 3, 3, 3, 3, 3, 3, 3,
                4, 4, 4, 4, 4, 4, 4, 4, 4,
                5, 5, 5, 5, 5, 5, 5, 5, 5,
                6, 6, 6, 6, 6, 6, 6, 6, 6,
                7, 7, 7, 7, 7, 7, 7, 7, 7,
                8, 8, 8, 8, 8, 8, 8, 8, 8]

  COLUMNS =    [0, 1, 2, 3, 4, 5, 6, 7, 8,
                0, 1, 2, 3, 4, 5, 6, 7, 8,
                0, 1, 2, 3, 4, 5, 6, 7, 8,
                0, 1, 2, 3, 4, 5, 6, 7, 8,
                0, 1, 2, 3, 4, 5, 6, 7, 8,
                0, 1, 2, 3, 4, 5, 6, 7, 8,
                0, 1, 2, 3, 4, 5, 6, 7, 8,
                0, 1, 2, 3, 4, 5, 6, 7, 8,
                0, 1, 2, 3, 4, 5, 6, 7, 8]

  BLOCKS =     [0, 0, 0, 1, 1, 1, 2, 2, 2,
                0, 0, 0, 1, 1, 1, 2, 2, 2,
                0, 0, 0, 1, 1, 1, 2, 2, 2,
                3, 3, 3, 4, 4, 4, 5, 5, 5,
                3, 3, 3, 4, 4, 4, 5, 5, 5,
                3, 3, 3, 4, 4, 4, 5, 5, 5,
                6, 6, 6, 7, 7, 7, 8, 8, 8,
                6, 6, 6, 7, 7, 7, 8, 8, 8,
                6, 6, 6, 7, 7, 7, 8, 8, 8]

  $boards = []

  class Solver

    def initialize(board_or_string)
      @board = board
    end

  end

  class Board
    attr_reader :board, :cells, :rows, :columns, :blocks

    def initialize(board)
      @board = board
      @cells = [] #All Cell instances
      @rows = [] #9 Group instances
      @columns = [] #9 Group instances
      @blocks = [] #9 Group instances
    end
    def parse
      9.times { @rows << Group.new }
      9.times { @columns << Group.new }
      9.times { @blocks << Group.new }
      @board.chars.each_with_index do |char, index|
        cell = Cell.new(char.to_i, ROWS[index], COLUMNS[index], BLOCKS[index])
        @cells << cell
        @rows[cell.row].cells << cell
        @columns[cell.column].cells << cell
        @blocks[cell.block].cells << cell
      end
    end

    def solve
      all = [0,1,2,3,4,5,6,7,8,9]
      while @board.include?("0")
        length = []
        @cells.each_with_index do |cell, index|
          next if cell.value != 0
          row = @rows[ROWS[index]].values
          column = @columns[COLUMNS[index]].values
          block = @blocks[BLOCKS[index]].values
          values = all - row - column - block
          length << values.length
          cell.value = values[0] if values.length == 1
        end
        @board = @cells.collect { |cell| cell.value }.join
        p @board
        return @board unless length.include?(1)
      end
      p @board
    end
  end

  class Group #Rows, Columns, and Blocks
    attr_accessor :cells

    def initialize
      @cells = [] #All of the Cell instances in the correct Group instance
    end

    def values
      @cells.collect { |cell| cell.value }
    end

  end

  class Cell
    attr_accessor :value, :row, :column, :block

    def initialize(value, row, column, block)
      @value = value
      @possible_values = []
      @row = row
      @column = column
      @block = block
    end

  end

end

board = SudokuSolver::Board.new('302609005500730000000000900000940000000000109000057060008500006000000003019082040')
board.parse
board.solve




