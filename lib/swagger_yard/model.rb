module SwaggerYard
  #
  # Carries id (the class name) and properties for a referenced
  #   complex model object as defined by swagger schema
  #
  class Model
    attr_reader :id

    def self.from_yard_objects(yard_objects)
      from_yard_object(yard_objects.detect {|o| o.type == :class })
    end

    def self.from_yard_object(yard_object)
      from_tags(yard_object.tags) if yard_object
    end

    def self.from_tags(tags)
      new.tap do |model|
        model.parse_tags(tags)
      end
    end

    def initialize
      @properties = []
    end

    def valid?
      !id.nil?
    end

    def parse_tags(tags)
      tags.each do |tag|
        case tag.tag_name
        when "model"
          @id = tag.text
        when "property"
          @properties << Property.from_tag(tag)
        end
      end

      self
    end

    def properties_model_names
      @properties.map(&:model_name).compact
    end

    def to_h
      raise "Model is missing @model tag" if id.nil?

      {
        "id" => id,
        "properties" => Hash[@properties.map {|property| [property.name, property.to_h]}],
        "required" => @properties.select(&:required?).map(&:name)
      }
    end
  end
end
