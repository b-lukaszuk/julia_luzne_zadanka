function get_line(fst_last_char::Char, fill::String, fill_length::Int,
                  add_end_char::Bool)::String
    fst_last_char * fill^fill_length * (add_end_char ? fst_last_char : "")
end

function get_row_line(no_of_cols::Int, row_sep::Bool)
    result::String = ""
    for i in 1:no_of_cols
        result = result * get_line(row_sep ? '+' : '|',
                                   row_sep ? " -" : "  ", 4, i == no_of_cols)
    end
    result
end

function get_row(cells_per_row::Int)::String
    row::String = ""
    for j in 1:4
        row = row * get_row_line(cells_per_row, j == 1) * "\n"
    end
    row
end

function get_square(cells_per_row::Int)::String
    square::String = ""
    for i in 1:cells_per_row
        square = square * get_row(cells_per_row)
    end
    square * get_row_line(cells_per_row, true)
end

function main()
    println("Task2. Printing grid examples.")
    for i in 1:4
        println("\nGrid " * string(i) * "x" * string(i) * ":")
        println(get_square(i))
    end
    println("\nThat's all. Goodbye!.")
end

main()
