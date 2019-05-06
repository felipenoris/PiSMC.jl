
module Multithread

using Base.Threads
import Random
import Future

# thread-local seeds for rand()
function seed_per_thread() :: Vector{Random.MersenneTwister}
    m = Random.MersenneTwister(1)
    return [m; accumulate(Future.randjump,
                          fill(big(10)^20,
                          nthreads()-1),
                          init=m)]
end

# returns the number of simulations
# for the current thread
function thread_num_sims(total_num_sims::Integer)
    n = nthreads()
    dv = div(total_num_sims, n)
    md = mod(total_num_sims, n)

    if dv == 0
        # degenerates to single-threaded
        if threadid() == 1
            return total_num_sims
        else
            return 0
        end
    else
        if threadid() != n
            return dv
        else
            return dv + md
        end
    end
end

# checks if we're running Julia in multithread mode
function check_julia_num_threads()
    if nthreads() == 1
        error("Run `export JULIA_NUM_THREADS=n`, n > 1, before launching Julia.")
    end
end

# with threading
function run_multithread(num_sims::T) :: Float64 where {T<:Integer}
    check_julia_num_threads()
    @assert num_sims > 0

    local acum = Threads.Atomic{Int}(0)
    local check_num_sims = Threads.Atomic{T}(0)

    seeds = seed_per_thread()

    @threads for tid in 1:nthreads()
        @assert tid == threadid()

        thread_seed = seeds[threadid()]
        thread_acum = 0
        local_num_sims = thread_num_sims(num_sims)

        for sim in 1:local_num_sims

            x = rand(thread_seed)
            y = rand(thread_seed)

            r = sqrt(x^2 + y^2)

            if r <= 1.0
                thread_acum += 1
            end
        end

        Threads.atomic_add!(acum, thread_acum)
        Threads.atomic_add!(check_num_sims, local_num_sims)
    end

    @assert check_num_sims[] == num_sims

    area = acum[] / num_sims
    return 4*area
end

end # module Threaded
