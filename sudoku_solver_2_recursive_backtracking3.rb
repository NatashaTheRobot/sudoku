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


  class Solver

    attr_accessor :board, :boards

    def initialize(board)
      @board = Board.new(board)
      @boards = []
    end

    def parse!
      @board.parse!
      @boards << board
    end

    def solve!
      @boards.delete_at(-1) if @boards.last.dead?
      p @boards.last
      if @boards.last.solved? && !@boards.last.dead?
         p "(maybe) solved: #{@boards.last.to_s}"
      else
        @boards << Marshal::load(Marshal.dump(@boards.last))
        @boards.last.guess!
        @boards.last.solve!
        self.solve!
      end

    end


  end

  class Board
    attr_reader :board, :cells, :rows, :columns, :blocks
    attr_accessor :dead

    def initialize(board)
      @board = board
      @cells = [] #All Cell instances
      @rows = [] #9 Group instances
      @columns = [] #9 Group instances
      @blocks = [] #9 Group instances
      @dead = false
    end

    def parse!
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

    def solve!
      all = [0,1,2,3,4,5,6,7,8,9]
      length = []
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
          cell.possible_values = values unless values.length == 1
        end
        @board = @cells.collect { |cell| cell.value }.join
        break unless length.include?(1)
      end

      # @cells.each_with_index do |cell, index|
      #   next if cell.value != 0
      #   row = @rows[ROWS[index]].values
      #   column = @columns[COLUMNS[index]].values
      #   block = @blocks[BLOCKS[index]].values
      #   values = all - row - column - block
      #   @dead = true if values == [0]
      #   length << values.length
      #   cell.value = values[0] if values.length == 1
      #   cell.possible_values = values unless values.length == 1
      # end

    end

    def solved?
      @cells.each do |cell|
        return false if cell.value == 0
      end
      return true
    end

    def to_s
      @cells.collect{|cell| cell.value}.join
    end

    def dead?
      if !@board.include?("0")
        @rows.each { |row| return @dead = true if row.sum != 45}
        @columns.each { |column| return @dead = true if row.sum != 45}
        @blocks.each { |block| return @dead = true if row.sum != 45}
      else
        return @dead = false
      end
    end

    def guess!
      @cells.each do |cell|
        if cell.possible_values.length >= 1
          cell.value = cell.possible_values[0]
          cell.possible_values.delete_at(0)
          break
        end
      end
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

    def sum
      values.inject(:+)
    end

  end

  class Cell
    attr_accessor :value, :row, :column, :block, :possible_values

    def initialize(value, row, column, block)
      @value = value
      @possible_values = []
      @row = row
      @column = column
      @block = block
    end

  end

end

 puzzle = SudokuSolver::Solver.new('302609005500730000000000900000940000000000109000057060008500006000000003019082040')
# puzzle = SudokuSolver::Solver.new('300000000050703008000028070700000043000000000003904105400300800100040000968000200')
#puzzle = SudokuSolver::Solver.new('000689100800000029150000008403000050200005000090240801084700910500000060060410000')
puzzle.parse!
puzzle.solve!

