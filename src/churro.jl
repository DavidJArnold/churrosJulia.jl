function churro(str;diagnostics = false,live = false)

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

    stack = Int64[]
    mem = zeros(Int64,1,1000)

    code,loops = parseCodeAndLoops(str)

    i = 1
    out = Array{String,1}[]
    filled  = 0

    global stack
    global mem
    global i
    global out
    global filled

    while i <= length(code)
        # number or command?
        currCode = code[i]
        if occursin(r"{[o*]}(=*)}",currCode) # it's a number
            push_(getNumber(currCode)) # push that number
            diagnostics && print("Number $(stack[1])\n")
        elseif occursin(r"{(=*){[o*]}",currCode) # it's a command
            opCode = churroLength(currCode)
            filled = currCode[end-1]=='*'
            if opCode == 0
                diagnostics && print("get\n")
                get_()
            elseif opCode == 1
                diagnostics && print("add\n")
                add()
            elseif opCode == 2
                diagnostics && print("subtract\n")
                sub()
            elseif opCode == 3 # open loop
                diagnostics && print("start loop\n")
                openLoop()
            elseif opCode == 4 # close loop
                diagnostics && print("end loop\n")
                closeLoop()
            elseif opCode == 5
                diagnostics && print("store\n")
                store()
            elseif opCode == 6
                diagnostics && print("retrieve\n")
                retrieve()
            elseif opCode == 7
                diagnostics && print("print int\n")
                printInt()
            elseif opCode == 8
                diagnostics && print("print char\n")
                printChar()
            elseif opCode == 9
                diagnostics && print("read\n")
                readChar()
            elseif opCode == 10
                diagnostics && print("exit\n")
                break
            end
        else
            error("$(code{i}) is not a churro")
        end
        if isempty(i)
            # if the code ends with a close-loop, break here
            break
        end

        # display diagnostics for first 10 memory cells
        diagnostics && diagnose(code)

        # increment i to go to the next character
        i += 1
    end

    return out
end

# Parse numbers
function getNumber(s)
    val = churroLength(s);
    sgn = occursin("*",s) ? -1 : 1
    return sgn*val
end

function churroLength(s)
    return length(findall(r"(=)",s))
end

# Stack management

function push_(A)
    global stack
    if isempty(stack)
        stack = [A]
    else
        stack = hcat(A,stack)
    end

end

function pop()
    global stack
    A = stack[1]
    stack = stack[2:end]
    return A
end

function peek(n)
    A = stack[n]
end

# does a pop or a peek depending on whether or not the churro is filled
function get_()
    if filled
        return peek(1)
    else
        return pop()
    end
end

function get2()
    if filled
        A = peek(1)
        B = peek(2)
    else
        A = pop()
        B = pop()
    end
    return A,B
end

# Function definitions (not control flow)

function add()
    A,B = get2()
    push_(A+B)
end

function sub()
    A,B = get2()
    push_(B-A)
end

function openLoop()
    if get==0
        # jump forwards
        # i = find(loops[i+1:end]==(loops[i]-1),1)+i+1
        i = findnext(loops.==loops[i],i+1)
    end
end

function closeLoop()
    if get!=0
        # loop again
        # i = find(loops(1:i-1)==loops(i),1,'last')
        i = findlast(loops.==loops[i-1],i-1)
    end
end

function store()
    A,B = get2
    mem[A+1] = B
end

function retrieve()
    A = get;
    if A+1>numel(mem)
        mem[A+1] = 0
    end
    push_(mem[A+1])
end

function printInt()
    global out
    A = string(get_())
    if isempty(out)
        out = [A]
    else
        out = join(hcat(out,A))
    end

    # live && disp(out[1])
end

function printChar()
    global out
    A = string(Char(get_()))
    if isempty(out)
        out = [A]
    else
        out = join(hcat(out,A))
    end
    # live && disp(out[1])
end

function readChar()
    s = readline()
    length(s)>1 && print("You may only enter one character at a time. Retaining $(s[1]) only.\n")
    push_(Int(s[1]))
end
#
# diagnostic function
function diagnose(code;N=10)
    print("Code location $i $(code[i])\n")
    print("Stack: $(stack[1:min(N,length(stack))])\n")
    print("Memory: $(mem[1:min(N,length(mem))])\n")
    print("Output: $(out[1:min(N,length(out))])\n")
end

# Parse code
function parseCodeAndLoops(str)
    code = [s.match for s in eachmatch(r"{(=*){[o*]}|{[o*]}(=*)}",str)]

    codeLen = length(code)

    # checking the loops are properly defined and getting positions
    loops = zeros(Int64,1,codeLen); # counts number of open loops
    for k = 1:codeLen
        if !isnothing(match(r"{==={.}",code[k]))
            loops[k:end] = loops[k:end] .+ 1;
        elseif !isnothing(match(r"{===={.}",code[k]))
            loops[k:end] = loops[k:end] .- 1;
        end
    end

    # If the loops are not properly defined
    if loops[end]!=0 || any(loops.<0)
        if any(loops.<0)
            error("Too many loops were closed")
        else
            error("Not enough loops were closed")
        end
    end

    return code, loops
end
