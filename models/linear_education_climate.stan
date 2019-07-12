
data {
  int<lower=0> N;
  vector[N] y; // support for fossil fuel tax
  vector[N] x; // years of education
}

parameters {
  real mu;
  real<lower=0> sigma;
}

model {
  y ~ normal(x * mu, sigma);
}

