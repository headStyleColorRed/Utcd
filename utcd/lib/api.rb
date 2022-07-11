require 'graphql/client'
require 'graphql/client/http'
require_relative 'queries'
require 'rest_client'
require_relative 'tools'
require 'json'

module API
  extend self
  extend Queries
  extend Tools

  def check_server_locales
    # Execute the query
    result = Queries::Client.query(Queries::RetrieveAllLocales)
    # Check for errors
    raise result.errors.first.message if result.errors.any?

    # Print array of locales
    puts '________ LOCALES ON SERVER ________'
    puts result.data.all_locales.map { |locale| "- #{locale}" }
  end

  def check_server_locales_for_platform(platform)
    # Execute the query
    result = Queries::Client.query(Queries::RetrieveAllLocalesForPlatform, variables: { platform: platform })
    # Check for errors
    raise result.errors.first.message if result.errors.any?

    # Print array of locales
    puts "________ LOCALES ON SERVER: #{platform.upcase}________"
    puts result.data.all_locales_for_platform.map { |locale| "- #{locale}" }
  end

  def create_segment_on_server(file_name, locale)
    # Execute the query
    result = Queries::Client.query(Queries::CreateSegment,
                                   variables: { language: locale, platform: platform, fileName: file_name })
    # Check for errors
    raise result.errors.first.message if result.errors.any?
  end

  ############################## A P I     V 2 ###########################################
  def upload_server_locale_file(path, locale)
    url = "#{Constants::BASE_URI}/upload?folder=#{locale}"
    response = RestClient.post url, { file: File.new(path, 'rb'), multipart: true }
    response.gsub(/"/, '').split('/').last
  end

  def retrieve_server_translations_for_locale(locale)
    # Execute the query
    url = "http://localhost:8080/files/#{locale}"
    response = RestClient.get url
    return JSON.parse(response.body)
  end

  def download_server_locale_file(path)
    url = "http://localhost:8080/files/#{path}"
    response = RestClient.get url
    return response.body
  end
end
