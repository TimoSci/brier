require 'rspec'
require_relative '../cli.rb'

TEST_FILE="#{APP_PATH}/data/testdata.yml"


describe CLI do

  cli = described_class.new(YAML::Store.new(TEST_FILE))

  it 'should retrurn a nil score for a newly intialized client' do
    expect(cli.score).to be nil
  end

  it 'should correctly parse the command line argument' do
    expect(cli.parse '0').to eq 0
    expect(cli.parse '0.0').to eq 0.0
    expect(cli.parse '1.0').to eq 1.0
    expect(cli.parse 'hello').to eq :hello
    expect(cli.parse 'hello123hello').to eq :hello123hello
  end

  it 'should record forecasts and return a score' do
    5.times do
      10.times do
        cli.submit rand.to_s
        cli.submit ["pass","fail"].sample
      end
      expect(cli.score).to be_between(0,2)
    end
  end

  it 'should compute the correct brier scores' do

    Forecast.clear_all
    cli.submit "1"
    cli.submit "pass"
    expect(cli.score).to eq 0.0

    Forecast.clear_all
    cli.submit "1"
    cli.submit "fail"
    expect(cli.score).to eq 2.0

    Forecast.clear_all
    cli.submit "0"
    cli.submit "pass"
    expect(cli.score).to eq 2.0

    Forecast.clear_all
    cli.submit "0"
    cli.submit "fail"
    expect(cli.score).to eq 0.0

    Forecast.clear_all
    cli.submit "1"
    cli.submit "fail"
    cli.submit "1"
    cli.submit "pass"
    expect(cli.score).to eq 1.0

  end


  it 'should reset the data store' do
    cli.submit "reset"
    expect(cli.score).to be nil
    10.times do
      cli.submit rand.to_s
      cli.submit ["pass","fail"].sample
    end
    cli.submit "reset"
    expect(cli.score).to be nil
  end

end
