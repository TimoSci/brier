# Database interface for YAML Data store

module YamlMappingClass

  def database
    @@database
  end

  def database=(db)
    @@database = db
    @@database.transaction{ @@database[klass] ||= []}
  end

  def klass
    (self.to_s.downcase+"s").to_sym # don't use #pluralize right now to keep things simple
  end

  def all
    database.transaction{ database[klass] }
  end

  def last
    database.transaction{ database[klass].last }
  end

  def clear_all
      database.transaction{ database[klass] = [] }
  end

end

module YamlMapping

  def find
  end

  def database
    @database ||= self.class.database
  end

  def save
    database.transaction do
       database[self.class.klass] << self.to_h #TODO #to_h is specific to Forecast and does not belong here
    end
  end

end
