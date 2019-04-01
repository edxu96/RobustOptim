# RobustOptimization
Introductory (adjustable) robust optimization by matrix computation with box uncertainty and budget of uncertainty.

author: Edward J. Xu, edxu96@outlook.com
last update date: April 1st, 2019
***

Detailed explanation can be found in file [Cookbook for Robust Optimization, EDXU](cookbook_edxu.pdf)

## Examples

Example 1: Production Planning with Uncertainty in Production Efficiency

Formulate a robust optimization model that decides the number of machines and production quantities for each product and machine to have minimal cost and cover the demand in all cases of production time deviation. Use a budget of uncertainty.

Problem description can be found in first page of file [exerciseSolution_productionPlanning.pdf](example_productionPlanning_dtu02435/exerciseSolution_productionPlanning.pdf). There are form of solutions in Julia, with one in matrix form and one in traditional form.
