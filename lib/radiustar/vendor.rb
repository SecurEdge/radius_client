class Vendor
  attr_reader :name, :id

  def initialize(name, id)
    @name = name
    @id = id
    @attributes = AttributesCollection.new self
  end

  def add_attribute(name, id, type)
    @attributes.add(name, id, type)
  end

  def find_attribute_by_name(name)
    @attributes.find_by_name(name)
  end

  def find_attribute_by_id(id)
    @attributes.find_by_id(id.to_i)
  end

  def attributes
    @attributes
  end
end
