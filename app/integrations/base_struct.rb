class BaseStruct < Dry::Struct
  transform_types do |type|
    if type.optional?
      type.omittable
    elsif type.default?
      type.constructor do |value|
        value.blank? ? Dry::Types::Undefined : value
      end
    else
      type
    end
  end
end
