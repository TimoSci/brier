module ScoreFunctions

# Score functions for scoring probability estimates
# For now only the Brier score is defined

  def single_brier_score(forecast,outcome)
    (forecast-outcome)**2
  end

  def brier_score(single_brier_scores)
    sample_size = single_brier_scores.size
    return nil if sample_size == 0
    single_brier_scores.sum/sample_size
  end

end
