class ThemeFieldSerializer < ApplicationSerializer
  attributes :name, :target, :value

  def target
    case object.target
    when 0 then "common"
    when 1 then "desktop"
    when 2 then "mobile"
    end
  end
end

class ChildThemeSerializer < ApplicationSerializer
  attributes :id, :name, :key, :created_at, :updated_at
end

class ThemeSerializer < ChildThemeSerializer
  attributes :color_scheme
  has_many :child_themes, serializer: ChildThemeSerializer, embed: :objects
  has_many :theme_fields, embed: :objects
end
