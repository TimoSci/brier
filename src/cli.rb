require 'pry'

require 'yaml/store'

DATA_LOCATION = './data.yml'


class Logger

  attr_reader :database

  def initialize(database=DATA_LOCATION)
    @database = YAML::Store.new(database)
    # @database.transaction{ @database[:current_forecast] ||= []}
    @database.transaction{ @database[:forecasts] ||= []}
  end

  def save(outcome)
    forecasts =  database.transaction{database[:forecasts]}
    database.transaction do
       # database[:forecasts] = (database[:forecasts]<<{time: Time.now.utc, forecast: self.forecast, outcome: outcome})
       binding.pry
       database[:forecasts] = forecasts<<{time: Time.now.utc, forecast: self.forecast, outcome: outcome}
    end
    self.forecast = nil
  end

  def forecast=(value) #TODO: store state in memory (environment variable?)
    database.transaction{database[:current_forecast] = value}
  end

  def forecast #TODO: store state in memory not disk (environment variable?)
    database.transaction{database[:current_forecast]}
  end

end


module ScoreFunctions

# Score functions for scoring probability estimates
# For now only the Brier score is defined

  def single_brier_score(forecast,outcome)
    (forecast-outcome)**2
  end

  def brier_score(single_brier_scores)
    single_brier_scores.sum/single_brier_scores.size
  end

end


class CLI

# Command line interface methods
#
  attr_reader :logger

  include ScoreFunctions

  def initialize(logger = Logger.new)
    # @state ||= :ready
    # @state = logger.state
    @logger = logger
  end

  def submit(argument)
    if logger.forecast
      submit_result(argument)
    else
      submit_query(argument)
    end
  end

  def submit_query(argument)
    if /\A\d*\.?\d+\z/ =~ argument
      enter_forecast(argument.to_f)
    else
      parse(argument)
    end
  end

  def enter_forecast(probability)
    raise "Probability must be between 0 and 1" unless probability >=0 && probability <= 1
    # current_probability = probability
    logger.forecast = probability
  end

  def parse(command)
    valid_commands = [:pass,:fail,:score,:trend,:reset]
    command = command.to_sym
    raise "invalid command! \n valid commands are #{valid_commands.inspect}" unless valid_commands.include? command
    if [:pass,:fail].include? command
       outcome = {pass: 1, fail: 0}
       # binding.pry
       logger.save(outcome[command])
    end
  end

  #
  # private
  #
  # def state=(value)
  #   @logger.state = value
  # end
  #
  # def state
  #   @logger.state
  # end

end




#ARGV.first



c = CLI.new
# system("VAR=2")

# logger = Logger.new
# zache.put(:status,:ready)

binding.pry
