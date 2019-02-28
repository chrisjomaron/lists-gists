# frozen_string_literal: true

require 'net/https'
require 'json'
require 'optparse'
require 'pp'

# Simple; uses no extra gems
# Treat updated and deleted gists as 'new' for notification purposes.
# TODO: automate some tests
class ListsGists
  attr_reader :username, :verbose, :api_stem

  def initialize(username, verbose, api_stem)
    @username = username
    @verbose = verbose
    @api_stem = api_stem
    @current_gists = []
    @previous_gists = []
    @gists_file = "#{@username}.json"
  end

  # Convenience method to return payload from GET request
  def fetch_payload(url)
    puts "Connecting to #{url}..." if @verbose
    response = Net::HTTP.get_response(URI(url))
    case response
    when Net::HTTPSuccess then
      puts 'Received JSON payload:', response.body if @verbose
      response.body
    else
      puts "Error code: #{response.value}"
      exit
    end
  end

  # Receives JSON and returns array of gist hashes (gist urls and timestamps)
  def json_to_array(json_payload)
    array = []
    json_payload.each do |line|
      array << { 'url' => line['url'], 'updated_at' => line['updated_at'] }
    end
    array
  end

  def read_previous_gists
    # Attempt to populate array of previous gists, read from the state file
    begin
      old = JSON.parse(File.read(@gists_file))
      @previous_gists = json_to_array(old)
      puts "Read previous gists from '#{@gists_file}':", @previous_gists if @verbose
    rescue Errno::ENOENT
      puts "File '#{@gists_file}' not found. No gists seen before?"
    end
  end

  def retrieve_current_gists
    # Now fetch current gists from GitHub API
    gists_url = "#{@api_stem}/users/#{@username}/gists"
    json_payload = JSON.parse(fetch_payload(gists_url))
    @current_gists = json_to_array(json_payload)
    puts 'Parsed CURRENT gists from API:', @current_gists if @verbose
  end

  def show_diffs
    puts 'Calculating difference between previous and current:' if @verbose
    new_gists = @current_gists - @previous_gists
    deleted_gists = @previous_gists - @current_gists

    if new_gists.empty?
      puts "Sorry, no new gists for #{@username}"
    else
      puts 'Found new gists:', new_gists
    end

    puts 'Detected a deleted gist:', deleted_gists unless deleted_gists.empty?
  end

  def write_current_gists
    # Write all current gists back to the user's state file
    File.open(@gists_file, 'w') { |f| f.write(JSON.generate(@current_gists)) }
  end

  def lists_gists
    read_previous_gists
    retrieve_current_gists
    show_diffs
    write_current_gists
  end
end

# Parse the command line options, using Ruby built-in
options = { username: 'defunkt',
            verbose: false,
            api_stem: 'https://api.github.com' }
OptionParser.new do |opts|
  opts.banner = 'Usage: lists_gists.rb [options]'

  # display usage banner
  opts.on('-h', '--help', 'Show this help message') do
    puts opts
    exit
  end

  # optional flag to show debug output
  opts.on('-v', '--verbose', 'Run verbosely') do
    options[:verbose] = true
  end

  # override default username, ARG is mandatory if switch is used
  opts.on('-u', '--username=NAME', 'username to poll for public gists') do |u|
    options[:username] = u
  end

  # override default api_stem, ARG is mandatory if switch is used
  opts.on('-a', '--api-stem=NAME', 'api stem to poll for public gists') do |a|
    options[:api_stem] = a
  end
end.parse!

pp "Options: #{options}" if @verbose

lister = ListsGists.new(options[:username],
                        options[:verbose],
                        options[:api_stem])

lister.lists_gists
