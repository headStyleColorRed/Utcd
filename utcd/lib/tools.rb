module Tools
  extend self

  def retrieve_localizable_folder_path
    localizable_file_path = Dir.glob("#{Dir.pwd}/**/*#{platform_extension}").first
    return nil if localizable_file_path.nil?

    localizable_file_path.gsub(%r{/[^/]+$}, '')
  end

  def retrieve_files_in_locale(locale)
    localizable_folder_path = retrieve_localizable_folder_path
    return nil if localizable_folder_path.nil?

    if platform == 'ios'
        Dir.glob("#{localizable_folder_path}/#{locale}#{platform_extension}/*.strings")
    elsif platform == 'android'
        Dir.glob("#{localizable_folder_path}/#{platform_extension}-#{locale}/strings_*.xml")
    else
        raise "Platform not supported"
    end
  end

  def platform
    ios_folder = Dir.glob("#{Dir.pwd}/**/*.lproj").first
    return 'ios' unless ios_folder.nil?

    android_folder = Dir.glob("#{Dir.pwd}/**/strings_*.xml").first
    return 'android' unless android_folder.nil?

    raise Error, 'No localizable files in project' if localizable_file_path.nil?
  end

  def platform_extension
    platform == 'ios' ? '.lproj' : 'values'
  end

  def remove_missing_files(server_files, locale)
    local_files = Dir.glob("#{retrieve_localizable_folder_path}/#{locale}#{platform_extension}/*.strings")

    # Iterate over localizable folder path files
    for file in local_files
        # Get file name
        file_name = file.split('/').last.split('.').first + '.csv'
        # check if exists on server
        if !server_files.include?(file_name)
            # remove from server files
            File.delete(file)
            puts "Removed file \"#{file_name}\" locally"
        end
    end
  end

  def generate_ios_hash(file)
    Apfel.parse(file).key_values
  end

  def generate_android_hash(file)
    strings = {}
    xml_file = File.open(file)

    parser = Nokogiri::XML(xml_file) do |config|
      config.strict.noent
    end

    parser.xpath("//string").each do |node|
      if !node.nil? && !node["name"].nil?
        strings.merge!(node["name"] => node.inner_html)
      end
    end

    xml_file.close

    strings.map { |key, value| Hash[*[key, value]]}
  end

  def generate_local_csv_file(locale, file, hash)
    csv_file_path = "#{Dir.pwd}/lib/csv_files/#{locale}/#{file.split('/').last.split('.').first}.csv"

    s = CSV.generate do |csv|
      hash.each do |x|
        # Skip if key is empty
        # next if x.keys.first.nil?
        csv << [x.keys.first, x.values.first]
      end
    end

    File.write(csv_file_path, s)
    return csv_file_path
  end

  def generate_server_csv_file(content, locale, file)
    hashed_content = Hash.new
    content.each do |line|
        hashed_content[line.split(",")[0]] = line.split(",")[1]
    end

    # Save to csv folder
    csv_file_path = "#{Dir.pwd}/lib/csv_files/#{locale}/#{file}"

    s = CSV.generate do |csv|
        hashed_content.each do |x|
          csv << [x.first, x.last]
        end
     end

    File.write(csv_file_path, s)
    return csv_file_path
  end

  def create_locale_folder(locale)
    directory_path = "#{Dir.pwd}/lib/csv_files/#{locale}"
    # Check if locale directory already exists
    if File.directory?(directory_path) == true then return end

    # Create locale folder
    Dir.mkdir directory_path

    return directory_path
  end
end
