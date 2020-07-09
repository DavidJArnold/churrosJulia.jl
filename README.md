# churrosJulia: Churro interpreter for Julia

[![Build Status](https://travis-ci.com/DavidJArnold/churrosJulia.jl.svg?branch=master)](https://travis-ci.com/DavidJArnold/churrosJulia.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/DavidJArnold/churrosJulia.jl?svg=true)](https://ci.appveyor.com/project/DavidJArnold/churrosJulia-jl)
[![Coverage](https://codecov.io/gh/DavidJArnold/churrosJulia.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/DavidJArnold/churrosJulia.jl)
[![Coverage](https://coveralls.io/repos/github/DavidJArnold/churrosJulia.jl/badge.svg?branch=master)](https://coveralls.io/github/DavidJArnold/churrosJulia.jl?branch=master)

[Churro](https://esolangs.org/wiki/Churro) is a stack-base esolang the uses churros as code elements. See also the [official Haskell implementation](https://github.com/TheLastBanana/Churro/).

This implementation uses a dictionary for memory and an array for the stack.

# Usage and installation

To use this package first add it using `Pkg`: `add https://github.com/DavidJArnold/churrosJulia.jl`.

Then `using churrosJulia` includes the module and you can run churro code in a string `str` by doing `out = churro(str)`, where `out` contains the output formatted as a string.

For debugging purposes `out = churro(str, diagnostics=true)` prints out information such as stack contents, memory contents, current code point, etc. as the program runs.
