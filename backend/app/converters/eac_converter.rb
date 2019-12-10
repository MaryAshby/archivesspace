require_relative 'converter'
require_relative 'lib/eac_base_map'

class EACConverter < Converter
  extend EACBaseMap

  require_relative 'lib/xml_dom'
  include ASpaceImport::XML::DOM

  def self.instance_for(type, input_file)
    new(input_file) if type == 'eac_xml'
  end

  def self.import_types(_show_hidden = false)
    [
      {
        name: 'eac_xml',
        description: 'Import EAC-CPF records from an XML file'
      }
    ]
  end
end

EACConverter.configure do |config|
  config.init_map(EACConverter.EAC_BASE_MAP)
end
