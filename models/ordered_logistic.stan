data {
  int<lower=2> K; // number of possible responses (i.e. items on likert scale)
  int<lower=0> N; // number of samples with responses
  int<lower=1,upper=K> response[N]; // support for carbon tax; response on likert scale
  vector[N] education; // years of education
}

parameters {
  real beta; // effect of education on carbon tax support
  ordered[K-1] c; // cutpoints
}

model {
  beta ~ normal(0, 1);
  
  for (n in 1:N)
    response[n] ~ ordered_logistic(education[n] * beta, c);
}
