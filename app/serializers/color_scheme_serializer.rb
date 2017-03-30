class ColorSchemeSerializer < ApplicationSerializer
  attributes :id, :name, :is_base
  has_many :colors, serializer: ColorSchemeColorSerializer, embed: :objects
end
