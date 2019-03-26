# Robust Optimization
# Version: 1.0
# Author: Edward J. Xu, edxu96@outlook.com
# Date: March 26th, 2019
module RobustMilp_EDXU
    export RobustMilp
    using JuMP
    using GLPKMathProgInterface
    using PrettyTables
    function RobustMilp(; n_x, n_y, vec_min_y, vec_max_y, vec_c, vec_f, vec_b,
        mat_a, mat_b, epsilon, timesIterationMax)
