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
vec_timeDevProd = readxl(file, "timeDevProd!B2:B11")
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
vec_max_y = hcat(repeat([10], num_y))
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
for i = 1: 10
    for j = 1: 4
        mat_b_2[(4 * i - 4 + j), j] = mat_prodOnMachine[i, j]
    end
end
mat_b = vcat(mat_b_1, mat_b_2)
# mat_a_nominal
mat_a_nominal = zeros(4, 40)
for i = 1: 10
    for j = 1: 4
        mat_a_nominal[j, (4 * i - 4 + j)] = vec_timeProd[i]
    end
end
mat_a_hat = zeros(4, 40)
for i = 1: 10
    for j = 1: 4
        mat_a_hat[j, (4 * i - 4 + j)] = vec_timeDevProd[i]
    end
end
mat_b_nominal = zeros(4, 4)
for i = 1: 4
    mat_b_nominal[i, i] = - vec_timeAvai[i]
end
vec_b_norminal = hcat(zeros(4))
#
epsilon = 0.001
cap_gamma = 10
# 3. Begin Optimization ------------------------------------------------------------------------------------------------
vec_result_y, vec_result_x, vec_result_z, mat_result_mu, vec_result_lambda = RobustMilpBoxBudget(num_x=num_x,
    num_y=num_y, vec_min_y=vec_min_y, vec_max_y=vec_max_y, vec_c=vec_c, vec_f=vec_f, vec_b=vec_b,
    mat_a=mat_a, mat_b=mat_b, mat_a_nominal=mat_a_nominal, mat_a_hat=mat_a_hat, mat_b_nominal=mat_b_nominal,
    vec_b_norminal=vec_b_norminal, epsilon=epsilon, cap_gamma=cap_gamma)
