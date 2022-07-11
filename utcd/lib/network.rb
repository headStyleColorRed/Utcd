require_relative 'constants'

module Network
  extend self
  extend Constants

  HTTP = GraphQL::Client::HTTP.new("#{Constants::BASE_URI}/graphql") do
    def headers(_context)
      { 'User-Agent': 'My Client' }
    end
  end

  Schema = GraphQL::Client.load_schema('./schema.json')

  def create_schema
    GraphQL::Client.dump_schema(Network::HTTP, './schema.json')
  end
end
