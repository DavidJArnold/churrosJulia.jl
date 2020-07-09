function churro(str;diagnostics = false)

    # Churro            Operation
    # {{o}              pop A; discard A
    # {={o}             pop A, B; push (B + A)
    # {=={o}            pop A, B; push (B - A)
    # {==={o}           pop A; if A = 0, jump to churro after matching occurence of {===={o}
    # {===={o}          pop A; if A != 0, jump to churro after matching occurence of {==={o}
    # {====={o}         pop A, B; store B in memory location A
    # {======{o}        pop A; push the value in memory location A to stack
    # {======={o}       pop A; print A as an integer
    # {========{o}      pop A; print A as an ASCII character
    # {========={o}     read a single character from stdin and push it to the stack
    # {=========={o}	exit the program
    #
    # If filled (* instead of o) then peek instead of popping
    #
    # Number format {o}====} with value given by number of equal signs, and
    # filled churros corresponding to negative numbers

    code,loops = parseCodeAndLoops(str)

    # initialise global variables
    stack = Array{Int64,1}[]
    mem = Dict()
    i = 1
    out = Array{String,1}[]
    filled  = 0

    global stack
    global mem
    global i
    global out
    global filled
    global loops

    # step through code
    while i <= length(code)
        currCode = code[i]

        if occursin(r"{[o*]}(=*)}",currCode) # it's a number
            push_(getNumber(currCode)) # push that number
            diagnostics && print("Number $(stack[1])\n")
        elseif occursin(r"{(=*){[o*]}",currCode) # it's a command
            opCode = churroLength(currCode) # identify command
            filled = currCode[end-1]=='*'
            # now execute appriopriate action
            if opCode == 0 # pop and discard
                diagnostics && print("get\n")
                get_()
            elseif opCode == 1 # pop 2 and add
                diagnostics && print("add\n")
                add()
            elseif opCode == 2 # pop 2 and subtract
                diagnostics && print("subtract\n")
                sub()
            elseif opCode == 3 # open loop
                diagnostics && print("start loop\n")
                openLoop()
            elseif opCode == 4 # close loop
                diagnostics && print("end loop\n")
                closeLoop()
            elseif opCode == 5 # store in memory
                diagnostics && print("store\n")
                store()
            elseif opCode == 6 # retrieve from memory
                diagnostics && print("retrieve\n")
                retrieve()
            elseif opCode == 7 # print as integer
                diagnostics && print("print int\n")
                printInt()
            elseif opCode == 8 # print as character
                diagnostics && print("print char\n")
                printChar()
            elseif opCode == 9 # read character from stdin
                diagnostics && print("read\n")
                readChar()
            elseif opCode == 10 # exit
                diagnostics && print("exit\n")
                break # break to end execution
            end
        else
            error("$(code{i}) is not a churro")
        end

        # display diagnostics for first 10 memory cells
        diagnostics && diagnose(code)

        # increment i to go to the next character
        i += 1
    end

    return join(out) # combines output into a single string
end

# values of number churros
function getNumber(s)
    val = churroLength(s);
    sgn = occursin("*",s) ? -1 : 1
    return sgn*val
end

# number of = signs in a churro
function churroLength(s)
    return length(findall(r"(=)",s))
end

# Stack management functions

function push_(A) # add to stack
    global stack
    isempty(stack) ? stack = [A] : stack = vcat(A,stack)
end

function pop() # remove from stack
    global stack
    if length(stack)>1
        A = stack[1]
        stack = stack[2:end]
    else
        A = stack[1]
        stack = Array{Int64,1}[]
    end
    return A
end

function peek(n) # look at n-th stack element
    global stack
    return stack[n]
end

function get_() # pop/peek if the churro is/isn't filled
    global filled
    if filled
        return peek(1)
    else
        return pop()
    end
end

function get2() # pop/peek 2 elements as appropriate
    global filled
    if filled
        A = peek(1)
        B = peek(2)
    else
        A = pop()
        B = pop()
    end
    return A,B
end

# Function definitions

function add()
    A,B = get2()
    push_(A+B)
end

function sub()
    A,B = get2()
    push_(B-A)
end

function openLoop()
    if get_()==0
        global i
        global loops
        # jump forwards to after loop
        i = findnext(loops.==loops[i],i+1)
    end
end

function closeLoop()
    if get_()!=0
        global i
        global loops
        # loop again back to start
        i = findprev(loops.==loops[i+1],i-1)+1
    end
end

function store() # into memory
    global mem
    A,B = get2()
    mem[A] = B
end

function retrieve() # from memory
    global mem
    A = get_()
    if haskey(mem,A)
        push_(mem[A])
    else
        # if nothing is in that memory location, push 0
        push_(0)
    end
end

function printInt()
    global out
    A = string(get_())
    if isempty(out)
        out = join([A])
    else
        out = join(hcat(out,A))
    end
end

function printChar()
    global out
    A = string(Char(get_()))
    if isempty(out)
        out = join([A])
    else
        out = join(hcat(out,A))
    end
end

function readChar()
    s = readline()
    length(s)>1 && print("You may only enter one character at a time. Retaining $(s[1]) only.\n")
    push_(Int(s[1]))
end
#
# diagnostic function to help debugging
function diagnose(code;N=10)
    print("Code location $i $(code[i])\n")
    print("Stack: $(stack[1:min(N,length(stack))])\n")
    print("Memory:\n")
    for (key, value) in mem
        println("Location ", key, " = ", value)
    end
    print("Output: $(out[1:min(N,length(out))])\n")
end

# Parse code and work out where loops start/end
function parseCodeAndLoops(str)
    # first get churros from other text using a regex
    code = [s.match for s in eachmatch(r"{(=*){[o*]}|{[o*]}(=*)}",str)]

    codeLen = length(code)

    # checking the loops are properly defined and getting positions
    loops = zeros(Int64,1,codeLen); # counts number of open loops
    for k = 1:codeLen
        # use regexes to match both {==={o} and {==={*}
        if !isnothing(match(r"{==={.}",code[k]))
            loops[k:end] = loops[k:end] .+ 1;
        elseif !isnothing(match(r"{===={.}",code[k]))
            loops[k:end] = loops[k:end] .- 1;
        end
    end

    # If the loops are not properly defined
    if !isempty(loops) && (loops[end]!=0 || any(loops.<0))
        if any(loops.<0)
            error("Too many loops were closed")
        else
            error("Not enough loops were closed")
        end
    end

    return code, loops
end
