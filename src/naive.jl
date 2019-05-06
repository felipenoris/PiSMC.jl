
function run_naive(num_sims::Integer) :: Float64

    # `x` and `y` are vectors
    x = rand(Float64, num_sims)
    y = rand(Float64, num_sims)

    # dot-syntax: broadcast
    r = sqrt.( x.^2 + y.^2 )

    area = mapreduce(
                     el -> el <= 1.0 ? 1.0 : 0.0, # map
                     +, # reduce
                     r) / num_sims
    return 4*area
end
