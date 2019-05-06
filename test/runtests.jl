
using Distributed # addprocs, @everywhere
using BenchmarkTools # @btime
using UnicodePlots # barplot on terminal
using Statistics # mean
using Base.Threads
using PiSMC

# checks if we're running Julia in multithread mode
PiSMC.Multithread.check_julia_num_threads()

qty_workers = 4
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

num_sims = 100_000_000

@info("naive...")
naive_bench = @benchmark PiSMC.run_naive(num_sims)
@info("singlethread...")
singlethread_bench = @benchmark PiSMC.run_singlethread(num_sims)
@info("multithread...")
multithread_bench = @benchmark PiSMC.Multithread.run_multithread(num_sims)
@info("distributed...")
distributed_bench = @benchmark PiSMC.run_distributed(num_sims)

plt = barplot( [ "naive", "singlethread", "multithread ($(nthreads()) threads)", "Distributed ($qty_workers workers)"],
              [ round(mean(v.times)/1E9, digits=4) for v in [ naive_bench, singlethread_bench, multithread_bench, distributed_bench ]],
        title="Benchmark (seconds)")

show(plt)
