module Identifiers
  MAX_LENGTH = 50

  def id_0=(v)
    @id_0 = v
    modified!
  end

  def id_1=(v)
    @id_1 = v
    modified!
  end

  def id_2=(v)
    @id_2 = v
    modified!
  end

  def id_3=(v)
    @id_3 = v
    modified!
  end

  def self.included(base)
    base.repo_unique_constraint(:identifier,
                                message: 'That ID is already in use',
                                json_property: :id_0)
  end

  def self.format(identifier)
    identifier.compact.join('--')
  end

  def self.parse(identifier)
    ASUtils.json_parse(identifier || '[]')
  end

  def after_initialize
    # Split the identifier into its components and add the individual pieces as
    # variables on this instance.
    if self[:identifier]
      identifier = Identifiers.parse(self[:identifier])

      4.times do |i|
        instance_eval {
          @values[:"id_#{i}"] = identifier[i] if identifier[i] && !identifier[i].empty?
        }

        instance_variable_set("@id_#{i}", identifier[i])
      end
    end

    super
  end

  def before_validation
    # Combine the identifier into a single string and remove the instance variables we added previously.
    values = (0...4).map { |i| instance_variable_get("@id_#{i}") }

    self.identifier = if values.reject { |v| v.nil? || v.empty? }.empty?
                        # None of the id_* fields were set, so the whole identifier is NULL.
                        nil
                      else
                        JSON(values)
                      end

    4.times do |i|
      instance_eval {
        @values.delete(:"id_#{i}")
      }
    end

    super
  end

  def validate
    return super if (self.class.table_name === :resource) && identifier.nil?

    (0...4).each do |i|
      val = instance_variable_get("@id_#{i}")
      errors.add("id_#{i}".intern, "Max length is #{MAX_LENGTH} characters") if val && val.length > MAX_LENGTH
    end

    super
  end

  # take a string that looks like this: "[\"3422\",\"345FD\",\"3423ASDA\",null]"
  # and convert it into this: "3422-345FD-3423ASDA"
  def format_multipart_identifier
    self[:identifier].gsub('null', '')
                     .gsub!(/[\[\]]/, '')
                     .gsub(',', '')
                     .split('"')
                     .reject { |s| s.empty? }
                     .join('-')
  end
end
