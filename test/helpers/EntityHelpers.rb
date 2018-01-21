module EntityHelpers
  def present(object, entity)
    return entity.represent(object, serializable: true).stringify_keys unless object.kind_of?(Array)

    object.map { |element| entity.represent(element, serializable: true).stringify_keys }
  end
end