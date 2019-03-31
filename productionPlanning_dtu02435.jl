# Test for Robust Optimization
# Version: 1.0
# Author: Edward J. Xu, edxu96@outlook.com
# Date: March 26th, 2019
# 0. Set working path, install packages and use module -----------------------------------------------------------------
push!(LOAD_PATH, "$(homedir())/Desktop/Production Planning, Robust Optimization, DTU02435")
cd("$(homedir())/Desktop/Production Planning, Robust Optimization, DTU02435")
using ExcelReaders
using RobustMilp_EDXU
using LinearAlgebra
using JuMP
using GLPKMathProgInterface
# 1. Data Process ------------------------------------------------------------------------------------------------------
file = openxl("data.xlsx")
vec_timeProdDev = readxl(file, "timeProdDev!B2:B11")
vec_costInvest = readxl(file, "costInvest!B2:B5")
vec_costProd = readxl(file, "costProd!B2:B11")
vec_demand = readxl(file, "demand!B2:B11")
mat_prodOnMachine = readxl(file, "prodOnMachine!B2:E11")
vec_timeAvai = readxl(file, "timeAvai!B2:B5")
vec_timeProd = readxl(file, "timeProd!B2:B11")
# 2. Tranform to standard form -----------------------------------------------------------------------------------------
num_x = 40
num_y = 4
vec_min_y = hcat(zeros(4))
vec_max_y = hcat(repeat([100], num_y))
vec_c = hcat(zeros(40))
for i = 1: 4
    vec_c[(4 * i - 3): (4 * i), 1] = repeat([vec_costProd[i]], num_y)
end
vec_f = vec_costInvest
vec_b = hcat(repeat([0], 50))
vec_b[1: 10, 1] = vec_demand
# mat_a
mat_a_1 = zeros(10, 40)
for i = 1: 10
    mat_a_1[i, (4 * i - 3): (4 * i)] = repeat([1], 4)
end
mat_a_2 = zeros(40, 40)
for i = 1: 40
    mat_a_2[i, i] = -1
end
mat_a = vcat(mat_a_1, mat_a_2)
# mat_b
mat_b_1 = zeros(10, 4)
mat_b_2 = zeros(40, 4)
epsilon = 0.000001  # epsilon must be large enough.
# ??? It seems that the epsilon can make a difference in the final result, thought it's large enough.
for i = 1: 10
    for j = 1: 4
        mat_b_2[(4 * i - 4 + j), j] = mat_prodOnMachine[i, j] * 1 / epsilon
    end
end
mat_b = vcat(mat_b_1, mat_b_2)
# mat_a_bar
mat_a_bar = zeros(4, 40)
for i = 1: 10
    for j = 1: 4
        mat_a_bar[j, (4 * i - 4 + j)] = vec_timeProd[i]
    end
end
mat_a_hat = zeros(4, 40)
for i = 1: 10
    for j = 1: 4
        mat_a_hat[j, (4 * i - 4 + j)] = vec_timeProdDev[i]
    end
end
mat_b_bar = zeros(4, 4)
for i = 1: 4
    mat_b_bar[i, i] = - vec_timeAvai[i]
end
vec_b_bar = hcat(zeros(4))
# 3. Begin Optimization ------------------------------------------------------------------------------------------------
# When gamma = 0.3
vec_gammaCap_1 = zeros(4)
for m = 1:4
    vec_gammaCap_1[m] = 0.3 * sum([mat_prodOnMachine[p, m]] for p = 1: 10)[1]
end
obj_result_1, vec_result_y_1, vec_result_x_1, vec_result_z_1, mat_result_mu_1, vec_result_lambda_1 =
    RobustMilpBoxBudget(num_x=num_x, num_y=num_y, vec_min_y=vec_min_y, vec_max_y=vec_max_y, vec_c=vec_c, vec_f=vec_f,
    vec_b=vec_b, mat_a=mat_a, mat_b=mat_b, mat_a_bar=mat_a_bar, mat_a_hat=mat_a_hat, mat_b_bar=mat_b_bar,
    vec_b_bar=vec_b_bar, vec_gammaCap=vec_gammaCap_1)
# Date after-process
vec_result_prod_1 = zeros(10)
index = collect(0: 3) * 10
for i = 1: 10
    vec_result_prod_1[i] = sum(vec_result_x_1[index .+ i])
end
# When gamma = 0.0 -----------------------------------------------------------------------------------------------------
vec_gammaCap_2 = zeros(4)
for m = 1:4
    vec_gammaCap_2[m] = 0.0 * sum([mat_prodOnMachine[p, m]] for p = 1: 10)[1]
end
obj_result_2, vec_result_y_2, vec_result_x_2, vec_result_z_2, mat_result_mu_2, vec_result_lambda_2 =
    RobustMilpBoxBudget(num_x=num_x, num_y=num_y, vec_min_y=vec_min_y, vec_max_y=vec_max_y, vec_c=vec_c, vec_f=vec_f,
    vec_b=vec_b, mat_a=mat_a, mat_b=mat_b, mat_a_bar=mat_a_bar, mat_a_hat=mat_a_hat, mat_b_bar=mat_b_bar,
    vec_b_bar=vec_b_bar, vec_gammaCap=vec_gammaCap_2)
# Date after-process
vec_result_prod_2 = zeros(10)
index = collect(0: 3) * 10
for i = 1: 10
    vec_result_prod_2[i] = sum(vec_result_x_2[index .+ i])
end
# When gamma = 1.0 -----------------------------------------------------------------------------------------------------
vec_gammaCap_3 = zeros(4)
for m = 1:4
    vec_gammaCap_3[m] = 1.0 * sum([mat_prodOnMachine[p, m]] for p = 1: 10)[1]
end
obj_result_3, vec_result_y_3, vec_result_x_3, vec_result_z_3, mat_result_mu_3, vec_result_lambda_3 =
    RobustMilpBoxBudget(num_x=num_x, num_y=num_y, vec_min_y=vec_min_y, vec_max_y=vec_max_y, vec_c=vec_c, vec_f=vec_f,
    vec_b=vec_b, mat_a=mat_a, mat_b=mat_b, mat_a_bar=mat_a_bar, mat_a_hat=mat_a_hat, mat_b_bar=mat_b_bar,
    vec_b_bar=vec_b_bar, vec_gammaCap=vec_gammaCap_3)
# 4. Date after-process ------------------------------------------------------------------------------------------------
vec_result_prod_3 = zeros(10)
index = collect(0: 3) * 10
for i = 1: 10
    vec_result_prod_3[i] = sum(vec_result_x_3[index .+ i])
end
