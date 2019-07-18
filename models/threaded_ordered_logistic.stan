functions {
  vector lp_reduce(vector global_parameters, vector shard_parameters, real[] packed_reals, int[] packed_ints) {

    int shard_size = size(packed_ints);
    int k = cols(global_parameters) - 1;
    
    int response[shard_size] = packed_ints[1:shard_size];
    vector[shard_size] x = to_vector(packed_reals[1:shard_size]);

    real beta = global_parameters[1];
    vector[k-1] cutpoints = global_parameters[2:];

    vector[1] log_prob;

    log_prob[1] = ordered_logistic_lpmf(response | beta + x, cutpoints);
    return log_prob;
  }
}

data {
  int<lower=2> K; // number of possible responses (i.e. items on likert scale)
  int<lower=0> N; // number of samples with responses
  int<lower=1,upper=K> response[N]; // support for carbon tax; response on likert scale
  real education[N]; // years of education
}

transformed data {
  int n_shards = 7;
  int M = N/n_shards;
  int sharded_response[n_shards, M];
  real sharded_education[n_shards, M];
  
  vector[0] shard_parameters[n_shards];

  for (i in 1:n_shards) {
    int j = 1 + (i-1)*M;
    int k = i*M;
    sharded_response[i] = response[j:k];
    sharded_education[i] = education[j:k];
  }
}

parameters {
  vector[1] beta; // effect of education on carbon tax support
  ordered[K-1] cutpoints[1];
}

transformed parameters {
   vector[2] global_parameters = {beta, cutpoints[1]};
   vector[0] local_parameters[n_shards]; 
}

model {
  beta ~ normal(0, 1);
  target += sum(map_rect(lp_reduce, global_parameters, local_parameters, sharded_education, sharded_response));
}



