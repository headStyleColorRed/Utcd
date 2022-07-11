require_relative 'network'

module Queries
  extend Network
  extend self

  Client = GraphQL::Client.new(schema: Network::Schema, execute: Network::HTTP)

  RetrieveAllLocales = Client.parse <<-'GRAPHQL'
        query {
            allLocales
        }
  GRAPHQL

  RetrieveAllLocalesForPlatform = Client.parse <<-'GRAPHQL'
        query($platform: String!) {
            allLocalesForPlatform(input: { platform: $platform })
        }
  GRAPHQL

  CreateSegment = Client.parse <<-'GRAPHQL'
        mutation (
            $language: String!
            $platform: String!
            $fileName: String!
        ) {
            createTranslation(
                input: { language: $language, platform: $platform, fileName: $fileName }
            ) {
                id
                language
                platform
                fileName
            }
        }
  GRAPHQL

  RetrieveTranslationsForLocale = Client.parse <<-'GRAPHQL'
        query ($platform: String!, $locale: String!) {
            findTranslationsForLocale(input: { platform: $platform, locale: $locale }) {
                id
                language
                platform
                fileName
            }
        }
  GRAPHQL
end
