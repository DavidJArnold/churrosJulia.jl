using churrosJulia
using Test

include("helloWorld.jl") # contains a long Hellow World program


fibDirty = "{o}=} {o}=} push 2 1's
{o}==========} {o}==} {=={o} push 10
{==={*} peek stack, exit loop if it is 0
{o}=} push 1
{====={o} put 10 in memory 1
{={*} peek top 2 spots and push their sum
{o}=} push 1
{======{o} pop 1 get memory location 1
{*}=} push -1
{={o} pop 10 -1 push 10+-1
{===={*} exit loop if 10-1!=0
{{o} {======={o} pop and print 2nd"

fibClean = "{o}=} {o}=} {o}==========} {o}==} {=={o} {==={*} {o}=} {====={o}
{={*} {o}=} {======{o} {*}=} {={o} {===={*} {{o} {======={o}"

breakTest = "{o}=} {======={o} {=========={o} {o}=} {======={o}"

skipLoops1 = "{o}} {==={*} {o}=} {===={*} {======={o}"
skipLoops2 = "{o}=} {==={*} {o}} {===={*} {======={o} {======={o}"
skipLoops3 = "{o}} {==={*} {o}=} {===={*} {o}} {======={o} {======={o}"

loopParse1 = "{==={o} {===={o} {===={o} {==={o} {==={o}"
loopParse2 = "{==={o} {===={o} {==={o} {==={o} {===={o}"

invalidMem = "{o}==} {======{o} {======={o}"

@testset "churrosJulia.jl" begin
    @test churro("")==""
    @test churro("{o}====} {======={o} {{==o}")=="4"
    @test churro("{o}====} {o}====} {={o} {======={o}")=="8"
    @test churro(HelloWorld)=="Hello, World!"
    @test churro(fibDirty)=="55"
    @test churro(fibClean)=="55"
    @test churro(breakTest)=="1"
    @test churro(skipLoops1)=="0"
    @test churro(skipLoops2)=="01"
    @test churro(skipLoops3)=="00"
    @test churro(fibClean,diagnostics = true)=="55"
    @test try
        churro(loopParse1)
        "no error"
    catch e
        e.msg
    end == "Too many loops were closed"
    @test try
        churro(loopParse2)
        "no error"
    catch e
        e.msg
    end == "Not enough loops were closed"
    @test churro(invalidMem) == "0"
end
