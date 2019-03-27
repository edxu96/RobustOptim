# Robust Optimization
# Version: 1.0
# Author: Edward J. Xu, edxu96@outlook.com
# Date: March 26th, 2019
module RobustMilp_EDXU
    export RobustMilpBoxBudget
    using JuMP
    using GLPKMathProgInterface
    # using PrettyTables
    function RobustMilpBoxBudget(; num_x, num_y, vec_min_y, vec_max_y, vec_c, vec_f, vec_b, mat_a, mat_b,
        mat_a_nominal, mat_a_hat, mat_b_nominal, vec_b_norminal, epsilon, cap_gamma)
        num_row = length(mat_a_nominal[:,1])
        num_col = length(mat_a_nominal[1,:])
        if cap_gamma > num_col
            println("Error: cap_gamma is greater than num_row in nominal and hat data!")
        end
        println("---------------------------------------------------------\n",
                "---------------- 1/2. Begin Optimization ----------------\n",
                "---------------------------------------------------------\n")
        model = Model(solver = GLPKSolverMIP())
        @variable(model, vec_y[1: num_y], Int)
        @variable(model, vec_x[1: num_x] >= 0)
        @objective(model, Min, (transpose(vec_c) * vec_x + transpose(vec_f) * vec_y)[1])
        @constraint(model, vec_y[1: num_y] .<= vec_max_y)
        @constraint(model, vec_y[1: num_y] .>= vec_min_y)
        @constraint(model, mat_a * vec_x + mat_b * vec_y .>= vec_b)
        #
        @variable(model, vec_lambda[1: num_row] >= 0)
        @variable(model, mat_mu[1: num_row, 1: num_x] >= 0)
        @variable(model, vec_z[1: num_x])
        @constraint(model, - vec_z .<= vec_x)
        @constraint(model, vec_x .<= vec_z)
        for i = 1: num_row
            @constraint(model, transpose(mat_a_nominal[i, :]) * vec_x + cap_gamma * vec_lambda[i] +
                sum(mat_mu[i, :]) + transpose(mat_b_nominal[i, :]) * vec_y <= vec_b_norminal[i])
            @constraint(model, hcat(vec_lambda[i], num_x) + hcat(mat_mu[i, :]) .>=  hcat(mat_a_hat[i, :]) .* vec_z[:])
        end
        solve(model)
        vec_result_y = getvalue(vec_y)
        vec_result_x = getvalue(vec_x)
        vec_result_z = getvalue(vec_z)
        mat_result_mu = getvalue(mat_mu)
        vec_result_lambda = getvalue(vec_lambda)
        println("---------------------------------------------------------\n",
                "------------------ 2/2. Nominal Ending ------------------\n",
                "---------------------------------------------------------\n")
        return vec_result_y, vec_result_x, vec_result_z, mat_result_mu, vec_result_lambda
    end
end
