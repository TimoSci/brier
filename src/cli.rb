require 'pry'
require 'yaml/store'

require_relative '../config.rb'
require_relative 'score_functions.rb'

DATA_PATH = "#{APP_PATH}/data/"
DATA_FILENAME = 'forecasts.yml'

DATA_FILE = DATA_PATH+DATA_FILENAME

class Logger

  #TOD0 separate forecasts and current forecast into separate classes in an ORM style

  attr_reader :database

  def initialize(database=DATA_FILE)
    @database = YAML::Store.new(database)
    @database.transaction{ @database[:current_forecast] ||= nil}
    @database.transaction{ @database[:forecasts] ||= []}
  end

  def save(outcome)
    current_forecast = self.forecast
    entry = {time: Time.now.utc, probability: current_forecast, outcome: outcome}
    database.transaction do
       database[:forecasts] << entry
    end
    self.forecast = nil
    entry
  end

  def all_forecasts
    database.transaction{ database[:forecasts] }
  end


  def forecast=(value)  #TODO: store state in memory not disk (environment variable?)
    database.transaction{database[:current_forecast] = value}
  end

  def forecast
    database.transaction{database[:current_forecast]}
  end

  def clear_all
      database.transaction{
        database[:current_forecast] = nil
        database[:forecasts] = []
      }
  end

end


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
      database.transaction{
        database[klass] = nil
      }
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




# Forecast.database = (YAML::Store.new(DATA_FILE))
# f = Forecast.new
# f[:foo] = "bar"






class CLI

# Command line interface methods
#
  attr_reader :logger

  include ScoreFunctions

  def initialize(logger = Logger.new, database = YAML::Store.new(DATA_FILE))
    @logger = logger
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
    if logger.forecast
      submit_outcome(command)
    else
      submit_query(command)
    end
  end


  def enter_forecast(probability)
    raise "Probability must be between 0 and 1" unless probability >=0 && probability <= 1
    puts "Probability of outcome set to #{probability}"
    logger.forecast = probability
  end

  def submit_outcome(command)
    if [:pass,:fail].include? command
       outcome = {pass: 1, fail: 0}
       f = Forecast.new
       f[:outcome] = outcome[command]
       f.save_with_current
       # puts logger.save(outcome[command])
    else
      raise "Invalide outcome! Must be pass or fail"
    end
  end

  def submit_query(query)
    valid_queries = [:score,:trend,:reset]
    raise "invalid query! \n Valid queries are #{valid_queries.inspect}" unless valid_queries.include? query
    pp self.public_send(query)
  end


  def clear_data
    logger.clear_all
  end


  #queries

  def score
    forecasts = logger.all_forecasts
    brier_scores = forecasts.map do |forecast|
      single_brier_score(forecast[:probability],forecast[:outcome])
    end
    brier_score(brier_scores)
  end

  def trend
    "<<<palceholder for printing trend>>>"
  end

  def reset
    puts "Resetting data store and archiving old values... "
    filename = DATA_FILE+".archive_#{Time.now.tv_sec}"
    system "cp #{DATA_FILE} #{filename}"
    # puts "Reset datastore. Are you sure? (y/n)"
    # if gets == 'y'
      clear_data
    # end
  end


end
