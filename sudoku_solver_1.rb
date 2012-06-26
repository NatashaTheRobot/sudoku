# Instructions
# Write a console-based ruby app that reads a string representing an unsolved
# sudoku board and spits out the solution as a solved string Each consecutive 9
# digits of the board string would represent a row of the sudoku board.

# Info
# The board is composed of 81 total cells.
# The board is composed of 9 3x3 blocks.
# Each row of the board must contain (1..9)
# Each column of the board must contain (1..9)
# Each block must contain (1..9)
# Therefore, the sum of any block, column, or row must be 45.
# Each cell belongs to 3 relevant groups: its block, row, and column.

# Use this string to test your program
# '619030040270061008000047621486302079000014580031009060005720806320106057160400030'

# Generates random sudoku puzzles
# (1..81).map{0.+(rand(9))}.join

# A good resource: http://www.sudopedia.org/index.php/Solving_techniques
# =>               http://en.wikipedia.org/wiki/Sudoku_algorithms
# recursive backtracking http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking

# Plans
# Any cell with a value of '0' is considered unassigned. Any unassigned cell has many
# possible values. These possible values are calculated by checking the values of all
# cells in the target cell's block, row, and column. The possible values are generated
# by checking the current values of every cell in the target cell's group. The target
# cell's value can be any value that is not found elsewhere in it's groups.
#
# Steps
# Check the board and solve all situations where the cell has only one possible value.
# Set that as the new board and solve it again with the same criteria.
# Repeat until no cells have only a single possible solution.
# Check for cells with only 2 possible values.
# Assume the first value and generate the remainder of the board based on that assumed value.
# If it runs into a contradiction, backtrace to the assumption and alter it.
# Continue assuming and backtracing contradictory threads until board is solved.
#
#

#  0     1     2     3     4     5     6     7     8
#  9    10    11    12    13    14    15    16    17
# 18    19    20    21    22    23    24    25    26
# 27    28    29    30    31    32    33    34    35
# 36    37    38    39    40    41    42    43    44
# 45    46    47    48    49    50    51    52    53
# 54    55    56    57    58    59    60    61    62
# 63    64    65    66    67    68    69    70    71
# 72    73    74    75    76    77    78    79    80


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
        @cells.each_with_index do |cell, index|
          next if cell.value != 0
          row = @rows[ROWS[index]].values
          column = @columns[COLUMNS[index]].values
          block = @blocks[BLOCKS[index]].values
          values = all - row - column - block
          cell.value = values[0] if values.length == 1
        end
        @board = @cells.collect { |cell| cell.value }.join
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

board = SudokuSolver::Board.new('619030040270061008000047621486302079000014580031009060005720806320106057160400030')
board.parse
board.solve




