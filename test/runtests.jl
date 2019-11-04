
using Distributed # addprocs, @everywhere
using BenchmarkTools # @btime
using UnicodePlots # barplot on terminal
using Statistics # mean
using Base.Threads
using PiSMC

# checks if we're running Julia in multithread mode
PiSMC.Multithread.check_julia_num_threads()

qty_workers = 8
addprocs(qty_workers)

@everywhere begin
    using Pkg
    Pkg.activate(joinpath(@__DIR__, ".."))

    using PiSMC

    # Warmup
    PiSMC.run_naive(2)
    PiSMC.run_singlethread(2)
    PiSMC.Multithread.run_multithread(2)
    PiSMC.run_distributed(2)
end

@info("Started $(length(workers())) workers")
@info("Threads available: $(nthreads())")

num_sims = 100_000_000

let
    naive_result = PiSMC.run_naive(num_sims)
    singlethread_result = PiSMC.run_singlethread(num_sims)
    multithread_result = PiSMC.Multithread.run_multithread(num_sims)
    distributed_result = PiSMC.run_distributed(num_sims)

    @info("Naive result: $naive_result")
    @info("Singlethread result: $singlethread_result")
    @info("Multithread result: $multithread_result")
    @info("Distributed result: $distributed_result")
end

@info("Benchmarking naive...")
naive_bench = @benchmark PiSMC.run_naive(num_sims)
@info("Benchmarking singlethread...")
singlethread_bench = @benchmark PiSMC.run_singlethread(num_sims)
@info("Benchmarking multithread...")
multithread_bench = @benchmark PiSMC.Multithread.run_multithread(num_sims)
@info("Benchmarking distributed...")
distributed_bench = @benchmark PiSMC.run_distributed(num_sims)

plt = barplot( [ "naive", "singlethread", "multithread ($(nthreads()) threads)", "Distributed ($qty_workers workers)"],
              [ round(mean(v.times)/1E9, digits=4) for v in [ naive_bench, singlethread_bench, multithread_bench, distributed_bench ]],
        title="Benchmark (seconds)")

show(plt)
