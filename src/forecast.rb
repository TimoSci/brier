# Forecast model with customized datastore interface
class Forecast < Hash

  extend YamlMappingClass
  include YamlMapping


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

end
