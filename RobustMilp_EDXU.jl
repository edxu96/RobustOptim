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
        mat_a_bar, mat_a_hat, mat_b_bar, vec_b_bar, vec_gammaCap)
        num_row = length(mat_a_bar[:,1])
        num_col = length(mat_a_bar[1,:])
        for i = 1: num_row
            if vec_gammaCap[i] > num_col
                println("Error: vec_gammaCap[$i] is greater than num_row in nominal and hat data!")
            end
        end
        println("---------------------------------------------------------\n",
                "--- 1/2. Robust MILP with Box Uncertainty and Budget ----\n",
                "---------------------------------------------------------\n")
        model = Model(solver = GLPKSolverMIP())
        @variable(model, vec_y[1: num_y], Int)
        @variable(model, vec_x[1: num_x] >= 0)
        @objective(model, Min, (transpose(vec_c) * vec_x + transpose(vec_f) * vec_y)[1])
        @constraint(model, vec_y[1: num_y] .<= vec_max_y)
        @constraint(model, vec_y[1: num_y] .>= vec_min_y)
        @constraint(model, mat_a * vec_x + mat_b * vec_y .>= vec_b)
        # Transformation of Box Uncertainty.
        @variable(model, vec_lambda[1: num_row] >= 0)
        @variable(model, mat_mu[1: num_row, 1: num_x] >= 0)
        @variable(model, vec_z[1: num_x] >= 0)
        @constraint(model, - vec_z .<= vec_x)
        @constraint(model, vec_x .<= vec_z)
        for i = 1: num_row
            # sum() of variables without coefficients can be used directly
            @constraint(model, transpose(mat_a_bar[i, :]) * vec_x + vec_gammaCap[i] * vec_lambda[i] +
                sum(mat_mu[i, :]) + transpose(mat_b_bar[i, :]) * vec_y <= vec_b_bar[i])
            @constraint(model, vec_lambda[i] .+ hcat(mat_mu[i, :]) .>=  hcat(mat_a_hat[i, :]) .* vec_z[:])
        end
        solve(model)
        obj_result = getobjectivevalue(model)
        vec_result_y = getvalue(vec_y)
        vec_result_x = getvalue(vec_x)
        vec_result_z = getvalue(vec_z)
        mat_result_mu = getvalue(mat_mu)
        vec_result_lambda = getvalue(vec_lambda)
        println("---------------------------------------------------------\n",
                "------------------ 2/2. Nominal Ending ------------------\n",
                "---------------------------------------------------------\n")
        return obj_result, vec_result_y, vec_result_x, vec_result_z, mat_result_mu, vec_result_lambda
    end
end
