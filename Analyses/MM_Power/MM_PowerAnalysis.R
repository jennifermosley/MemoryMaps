### Power Analysis for Memory Maps Project
# NOT A COMPLETE SCRIPT

## Network Inferences

# GPower used for calculating power of simple version of LMM.
# A priori, two-tailed linear regression with fixed effects, and a moderate effect size
# (O.3), yielded a sample size of 46.  

# Using Simulations with simr and lme4
# This will allow for a power analysis using a LMM test. This accounts for
# random effects.

# Install and load necessary packages
# install.packages("lme4")
# install.packages("simr")
library(lme4)
library(simr)

# Create an example dataset
# Each subject will have 24 nested levels of memories. Each level/memory will
# have an indegree and outdegree centrality value associated with the memory.
# Additionally, each memory will have a quality which will be the LMM outcome
# variable. 

subj <- factor(rep(c(1:50),each = 24))# Let's say 50 based on our rough GPower estimate. 
# This is accounting for 24 memories per subject. This is how our processed network
# data set looks. 

indegree <- 1:12 # 24 maximum possible edge connections to memory nodes
outdegree <- 1:12 # 24 maximum possible edge connections to memory nodes
selfQual1 <- 1:100 # transformativess measure is continuous from 1:100
selfQual2 <- 1:7 # changeabiliy measure is continuous from 1:7

toy <- data.frame(id=subj)

# Fit linear mixed model
model <- lmer(y ~ time + (1 | subject), data = data)
summary(model)

# Extend the model to a power analysis scenario
model_extended <- extend(model, along="subject", n=200) # Increase the number of subjects to 200 for the power analysis

# Perform power analysis
power_analysis <- powerSim(model_extended, nsim = 100) # Run 100 simulations

# Print the power analysis result
summary(power_analysis)