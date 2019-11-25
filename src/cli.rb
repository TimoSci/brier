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
    current_forecast = self.forecast
    database.transaction do
       database[:forecasts] << {time: Time.now.utc, forecast: current_forecast, outcome: outcome}
    end
    self.forecast = nil
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
    if /\A\d*\.?\d+\z/ =~ argument
      enter_forecast(argument.to_f)
    else
      submit_command(argument)
    end
  end

  def validate(command)
    command = command.downcase.to_sym
    valid_commands = [:pass,:fail,:score,:trend,:reset]
    raise "invalid command! \n valid commands are #{valid_commands.inspect}" unless valid_commands.include? command
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
    # current_probability = probability
    logger.forecast = probability
  end

  def submit_outcome(command)
    if [:pass,:fail].include? command
       outcome = {pass: 1, fail: 0}
       logger.save(outcome[command])
    else
      raise "Invalide outcome! Must be pass or fail"
    end
  end

  def submit_query(command)
    pp command
  end

  def clear_data
    logger.clear_all
  end


end




#ARGV.first



c = CLI.new
# system("VAR=2")

# logger = Logger.new
# zache.put(:status,:ready)

binding.pry
