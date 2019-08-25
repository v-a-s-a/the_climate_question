data {
  int<lower=2> K; // number of possible responses (i.e. items on likert scale)
  int<lower=0> N; // number of samples with responses
  int<lower=1,upper=K> response[N]; // support for carbon tax; response on likert scale
  vector[N] education; // years of education
}

parameters {
  real beta; // effect of education on carbon tax support
  ordered[K-1] cutpoints; // cutpoints
}

model {
  beta ~ normal(0, 1);
  for (i in 1:N)
    response[i] ~ ordered_logistic(education[i] * beta, cutpoints);
}

// simulate from the stan model
generated quantities {
  vector[N] response_sim;
  for(i in 1:N) {
    response_sim[i] = ordered_logistic_rng(education[i] * beta, cutpoints);
  }
}

