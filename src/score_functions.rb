module ScoreFunctions

# Score functions for scoring probability estimates
# For now only the Brier score is defined

  def binary_brier_score(forecast,outcome)
    # Forecast is probability of pass
    negative_outcome = {0 =>1, 1=> 0}[outcome]
    negative_forecast = 1 - forecast
    (forecast-outcome)**2 + (negative_forecast-negative_outcome)**2
  end

  def average(single_brier_scores)
    sample_size = single_brier_scores.size
    return nil if sample_size == 0
    single_brier_scores.sum/sample_size
  end

  def moving_average(brier_scores,size)
    brier_scores.each_cons(size).map(&:sum).map{|x| x/size}
  end

end
