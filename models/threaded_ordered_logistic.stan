functions {
  vector lp_reduce(vector beta, vector cutpoints, real[] education_shard, int[] response_shard) {

    int shard_size = size(response_shard);
    int y[shard_size] = response_shard[1:shard_size];
    real x[shard_size] = education_shard[1:shard_size];

    real lp = ordered_logistic_lpmf(y | beta[1] + to_vector(x), cutpoints);
    return to_vector([lp]);
  }
}

data {
  int<lower=2> K; // number of possible responses (i.e. items on likert scale)
  int<lower=0> N; // number of samples with responses
  int<lower=1,upper=K> response[N]; // support for carbon tax; response on likert scale
  real education[N]; // years of education
}

transformed data {
  // 7 shards
  // M = N/7 = 124621/7 = 6341
  int n_shards = 7;
  int M = N/n_shards;
  int sharded_response[n_shards, M];
  real sharded_education[n_shards, M];
  // split into shards
  for (i in 1:n_shards) {
    int j = 1 + (i-1)*M;
    int k = i*M;
    sharded_response[i] = response[j:k];
    sharded_education[i] = education[j:k];
  }
}

parameters {
  vector[1] beta; // effect of education on carbon tax support
  ordered[K-1] cutpoints[n_shards];
}

model {
  beta ~ normal(0, 1);
  target += sum(map_rect(lp_reduce, beta, cutpoints, sharded_education, sharded_response));
}



