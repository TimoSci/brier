# Forecast model with customized datastore interface
class Forecast < Hash

  extend YamlMappingClass
  include YamlMapping

  extend ScoreFunctions

  def self.current
    database.transaction{database[:current_forecast]}
  end

  def self.current=(proablility)
    database.transaction{database[:current_forecast] = proablility}
  end

  def self.clear_all
    current = nil
    super
  end

  def save
    self[:time] =  Time.now.utc
    super
  end

  def save_with_current
    self[:probability] = self.class.current
    save
    self.class.current = nil
  end

  # queries

  def self.stats
    forecasts = self.all
    forecasts.map do |forecast|
       forecast[:outcome]
    end
    brier_score(brier_scores)
  end

  def self.score
    forecasts = self.all
    brier_scores = forecasts.map do |forecast|
      single_brier_score(forecast[:probability],forecast[:outcome])
    end
    brier_score(brier_scores)
  end

end