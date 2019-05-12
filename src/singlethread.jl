
function run_singlethread(num_sims::Integer) :: Float64
    @assert num_sims > 0
    acum = 0

    for _ in 1:num_sims

        # `x` and `y` are scalars
        x = rand(Float64)
        y = rand(Float64)

        r = sqrt(x^2 + y^2)

        if r <= 1.0
            acum += 1
        end
    end

    area = acum / num_sims
    return 4*area
end
