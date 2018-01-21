class ParameterOverloadValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
  	system_parameter = Parameter.find_by(id: record.parameter_id)
    if system_parameter.blank? || !system_parameter.can_overloaded
      record.errors[attribute] << (options[:message] || 'can not be overloaded')
    end
  end
end