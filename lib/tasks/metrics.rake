require 'metric_fu'

MetricFu::Configuration.run do |config|
  #define which metrics you want to use
  config.metrics  = [:churn, :flog, :flay, :reek, :roodi, :rcov, :stats]
  config.graphs   = [:flog, :flay, :reek, :roodi]
  config.flay     = { :dirs_to_flay => ['lib'],
                      :minimum_score => 10  } 
  config.flog     = { :dirs_to_flog => ['lib']  }
  config.reek     = { :dirs_to_reek => ['lib']  }
  config.roodi    = { :dirs_to_roodi => ['lib'] }
  config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10}
  config.rcov     = { :environment => 'test',
                      :test_files => ['spec/*_spec.rb',
                                      'spec/**/*_spec.rb'],
                      :rcov_opts => ["--sort coverage", 
                                     "--no-html", 
                                     "--text-coverage",
                                     "--no-color",
                                     "--profile",
                                     "--exclude /gems/,/Library/"]}
  config.graph_engine = :bluff
end