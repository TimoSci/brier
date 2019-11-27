require 'pry'
require 'yaml/store'

require_relative '../config.rb'
require_relative 'score_functions.rb'

DATA_PATH = "#{APP_PATH}/data/"
DATA_FILENAME = 'forecasts.yml'

DATA_FILE = DATA_PATH+DATA_FILENAME




module YamlMappingClass

  def database
    @@database
  end

  def database=(db)
    @@database = db
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
       database[self.class.klass] << self.to_h
    end
  end

end


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




class CLI

# Command line interface methods
#

  include ScoreFunctions

  def initialize(database = YAML::Store.new(DATA_FILE))
    Forecast.database = database
  end

  def parse(argument)
    raise "Argument must not be empty" if !argument || argument.empty?
    return argument.to_f if /\A\d*\.?\d+\z/ =~ argument
    argument.scan(/(\d+)\/(\d+)/).tap do |rational|
      argument = Rational(rational.first,rational.second) if rational.size == 2
    end
    argument = argument.to_sym if /\D+/ =~ argument
    argument
  end

  # submissions
  #

  def submit(argument)
    argument = parse(argument)
    if Numeric === argument
      enter_forecast(argument)
    else
      submit_command(argument)
    end
  end

  def validate(command)
    valid_commands = [:pass,:fail,:score,:trend,:reset]
    raise "invalid command #{command}! \n valid commands are #{valid_commands.inspect}" unless valid_commands.include? command
    command
  end

  def submit_command(command)
    command = validate(command)
    if Forecast.current
      submit_outcome(command)
    else
      submit_query(command)
    end
  end


  def enter_forecast(probability)
    raise "Probability must be between 0 and 1" unless probability >=0 && probability <= 1
    puts "Probability of outcome set to #{probability}"
    Forecast.current = probability
  end

  def submit_outcome(command)
    if [:pass,:fail].include? command
       outcome = {pass: 1, fail: 0}
       f = Forecast.new
       f[:outcome] = outcome[command]
       f.save_with_current
       f
    else
      raise "Invalide outcome! Must be pass or fail"
    end
  end

  def submit_query(query)
    valid_queries = [:score,:trend,:reset]
    raise "invalid query! \n Valid queries are #{valid_queries.inspect}" unless valid_queries.include? query
    pp self.public_send(query)
  end


  def reset
    puts "Resetting data store and archiving old values... "
    filename = DATA_FILE+".archive_#{Time.now.tv_sec}"
    system "cp #{DATA_FILE} #{filename}"
    # puts "Reset datastore. Are you sure? (y/n)"
    # if gets == 'y'
      Forecast.clear_all
    # end
  end

  #
  # queries
  #

  def score
    forecasts = Forecast.all
    brier_scores = forecasts.map do |forecast|
      single_brier_score(forecast[:probability],forecast[:outcome])
    end
    brier_score(brier_scores)
  end

  def trend
    "<<<palceholder for printing trend>>>"
  end




end
