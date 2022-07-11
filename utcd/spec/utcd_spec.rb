RSpec.describe Utcd do
  describe 'tools tests' do
    it 'finds localizable files folder' do
      expect(Utcd.retrieve_localizable_folder_path).to eq("#{Dir.pwd}/spec/LocalizableFiles")
    end

    it 'finds all languages available locally' do
      localizables_folder = Utcd.retrieve_localizable_folder_path
      expect(Utcd.retrieve_locales).to eq(%w[de en es])
    end

    it 'reads localizable file into an array of hashes ' do
      localizable_file = "#{Dir.pwd}/spec/LocalizableFiles/en.lproj/Localizable.strings"
      expect(Utcd.read_localizable_file(localizable_file)[0]).to eq('next' => 'Next')
      expect(Utcd.read_localizable_file(localizable_file)[5]).to eq('love' => 'Love')
      localizable_file = "#{Dir.pwd}/spec/LocalizableFiles/de.lproj/Localizable.strings"
      expect(Utcd.read_localizable_file(localizable_file)[0]).to eq('next' => 'Nächste')
      expect(Utcd.read_localizable_file(localizable_file)[5]).to eq('love' => 'Liebe')
    end

    it 'returns platform' do
      expect(Utcd.platform).to eq('ios')
    end
  end
end
