# Test for Robust Optimization
# Version: 1.0
# Author: Edward J. Xu, edxu96@outlook.com
# Date: March 31th, 2019
# 0. Set working path, install packages and use module -----------------------------------------------------------------
push!(LOAD_PATH, "$(homedir())/Desktop/Production Planning, Robust Optimization, DTU02435")
cd("$(homedir())/Desktop/Production Planning, Robust Optimization, DTU02435")
using ExcelReaders
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
vec_gammaCap = zeros(4)
for m = 1:4
    vec_gammaCap[m] = 0.3 * sum([mat_prodOnMachine[p, m]] for p = 1: 10)[1]
end
# 2. Optimization ------------------------------------------------------------------------------------------------------
model = Model(solver = GLPKSolverMIP())
@variable(model, vec_y[1: 4] >= 0, Int)
@variable(model, mat_x[1: 4, 1: 10] >= 0)
@objective(model, Min, sum([vec_y[m] * vec_costInvest[m]] for m = 1: 4)[1] +
    sum([mat_x[m, p] * vec_costProd[p]] for m = 1: 4, p = 1: 10)[1])
@constraint(model, [p = 1: 10], sum([mat_x[m, p]] for m = 1: 4)[1] >= vec_demand[p])
@constraint(model, [m = 1: 4, p = 1: 10], mat_x[m, p] <= mat_prodOnMachine[p, m] * vec_y[m] * 1000000)
@variable(model, vec_lambda[1: 4] >= 0)
@variable(model, mat_mu[1: 4, 1: 10] >= 0)
# @variable(model, vec_z[1: 4] >= 0)
@constraint(model, [m = 1: 4], sum([vec_timeProd[p] * mat_x[m, p]] for p = 1: 10)[1] + vec_gammaCap[m] * vec_lambda[m] +
    sum([mat_mu[m, p]] for p = 1: 10)[1] <= vec_timeAvai[m] * vec_y[m])
@constraint(model, [m = 1: 4, p = 1: 10], vec_lambda[m] + mat_mu[m, p] >= vec_timeProdDev[p] * mat_x[m, p])  # vec_z[m]
# @constraint(model, [m = 1: 4, p = 1: 10], - vec_z[m] <= mat_x[m, p])
# @constraint(model, [m = 1: 4, p = 1: 10], mat_x[m, p] <= vec_z[m])
# @constraint(model, vec_y .== [23, 0, 13, 5])
solve(model)
obj = getobjectivevalue(model)
vec_result_y = getvalue(vec_y)
mat_result_x = getvalue(mat_x)
vec_result_prod = zeros(10)
for i = 1: 10
    vec_result_prod[i] = sum(mat_result_x[:,i])
end
