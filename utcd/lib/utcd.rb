require 'utcd/version'
require_relative 'tools'
require_relative 'api'
require 'apfel'
require 'csv'
require 'fileutils'
require 'nokogiri'

module Utcd
  extend Tools
  extend API

  def self.push(locale)
    # 1º. Check that the locale folder is not empty
    files = retrieve_files_in_locale(locale)
    puts "No files found for locale #{locale}" if files.nil? || files.empty?

    # Create locale folder
    directory_path = create_locale_folder(locale)

    # 2. Upload synchronously all files in the locale folder
    puts "Uploading files for locale #{locale}"
    files.each do |file|
      # Create csv file
      if platform == 'ios'
        dictionary = generate_ios_hash(file)
        path = generate_local_csv_file(locale, file, dictionary)
      elsif platform == 'android'
        dictionary = generate_android_hash(file)
        path = generate_local_csv_file(locale, file, dictionary)
      else
        raise "Platform not supported"
      end
      # Upload file
      file_path = upload_server_locale_file(path, locale)
      # Notify of progress
      puts "- #{file_path}"
    end

    FileUtils.rm_rf(directory_path)
  end

  def self.pull(locale)
    # 1. Get all server files for chosen locale
    server_files = retrieve_server_translations_for_locale(locale)
    # 2. Purge local files that aren't contained on the server
    remove_missing_files(server_files, locale)
    # 3Create locale folder
    directory_path = create_locale_folder(locale)
    # 4. Download all csv files from server for chosen locale
    server_files.each do |file|
        # Download file
        content = download_server_locale_file("#{locale}/#{file}").split("\n")
        # Create csv file from retireved server data
        csv_file_path = generate_server_csv_file(content, locale, file)
        # Convert csv file to localizable file
        if platform == 'ios'
            convert_csv_to_ios_file(locale, csv_file_path, file)
        elsif platform == 'android'
            convert_csv_to_android_file(locale, csv_file_path, file)
        end
        # Notify of progress
        puts "- #{file}"
    end
    FileUtils.rm_rf(directory_path)
  end

  def self.convert_csv_to_ios_file(locale, csv_file_path, file_name)
    locale_file_path = "#{retrieve_localizable_folder_path}/#{locale}.lproj/#{file_name.split('.').first}.strings"

    # Create file if it doesn't exist
    if File.exist?(locale_file_path) == false
        File.new(locale_file_path, "w")
    end

    File.open(locale_file_path, 'w') do |file|
        CSV.read(csv_file_path).each do |row|
            file.puts"\"#{row[0]}\" = \"#{row[1]}\";\n\n"
        end
    end
  end

  def self.convert_csv_to_android_file(locale, csv_file_path, file_name)
    locale_file_path = "#{retrieve_localizable_folder_path}/values-#{locale}/#{file_name.split('.').first}.xml"

    # Create file if it doesn't exist
    if File.exist?(locale_file_path) == false
        File.new(locale_file_path, "w")
    end

    File.open(locale_file_path, 'w') do |file|
        file.puts"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        file.puts"<resources>"
        CSV.read(csv_file_path).each do |row|
            file.puts"    <string name=\"#{row[0]}\">#{row[1]}</string>\n"
        end
        file.puts"<resources>"
    end
  end

  def self.change_file_encoding(file_path)
    File.open("#{file_path}.new", 'a') do |file|
        File.read(file_path).each_line do |line|
            new_line = line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?')
            file.puts new_line
        end
    end

    FileUtils.mv("#{file_path}.new", file_path)
  end
end
