require_dependency 'distributed_cache'
require_dependency 'stylesheet/compiler'
require_dependency 'stylesheet/manager'

class Theme < ActiveRecord::Base

  ENABLED_KEY = '7e202ef2-56d7-47d5-98d8-a9c8d15e57dd'

  @cache = DistributedCache.new('theme')

  belongs_to :color_scheme
  has_many :theme_fields

  before_create do
    self.key ||= SecureRandom.uuid
    true
  end

  after_save do
    changed_fields.each(&:save!)
    changed_fields.clear
    remove_from_cache!
  end

  after_destroy do
    remove_from_cache!
  end

  def self.lookup_field(key, target, field)
    return if key.blank?

    cache_key = "#{key}:#{target}:#{field}:#{ThemeField::COMPILER_VERSION}"
    lookup = @cache[cache_key]
    return lookup.html_safe if lookup

    target = target.to_sym
    theme = find_by(key: key)

    val = theme.resolve_baked_field(target, field) if theme

    (@cache[cache_key] = val || "").html_safe
  end

  def self.remove_from_cache!(key, broadcast = true)
    clear_cache!
    MessageBus.publish('/site_customization', key: key) if broadcast
  end

  def self.clear_cache!
    @cache.clear
  end


  def self.targets
    @targets ||= Enum.new(common: 0, desktop: 1, mobile: 2)
  end

  def child_themes
    return @child_themes if @child_themes
    @child_themes = []
    return [] unless id

    uniq = Set.new

    iterations = 0
    added = [id]
    while added.length > 0 && iterations < 5
      themes = Theme.where('id in (SELECT child_theme_id
                                  FROM child_themes
                                  WHERE parent_theme_id in (?))', added).to_a

      added = []
      themes.each do |theme|
        next if uniq.include? theme.id
        next if theme.id == id
        added << theme.id
        @child_themes << theme
      end

      iterations += 1
    end

    @child_themes
  end

  def resolve_baked_field(target, name)

    target = target.to_sym

    theme_ids = [self.id] + (child_themes.map(&:id) || [])
    fields = ThemeField.where(target: [Theme.targets[target], Theme.targets[:common]])
                       .where(name: name.to_s)
                       .includes(:theme)
                       .joins("JOIN (
                             SELECT #{theme_ids.map.with_index{|id,idx| "#{id} AS theme_id, #{idx} AS sort_column"}.join(" UNION ALL SELECT ")}
                            ) as X ON X.theme_id = theme_fields.theme_id")
                       .order('sort_column, target')
    fields.each(&:ensure_baked!)
    fields.map{|f| f.value_baked || f.value}.join("\n")
  end

  def remove_from_cache!
    self.class.remove_from_cache!(key)
  end

  def changed_fields
    @changed_fields ||= []
  end

  def set_field(target, name, value)
    name = name.to_s

    target_id = Theme.targets[target.to_sym]
    raise "Unknown target #{target} passed to set field" unless target_id

    field = theme_fields.find{|f| f.name==name && f.target == target_id}
    if field
      field.value = value
      changed_fields << field
    else
      theme_fields.build(target: target_id, value: value, name: name)
    end
  end

  def add_child_theme!(theme)
    ChildTheme.create!(parent_theme_id: id, child_theme_id: theme.id)
    @child_themes = nil
    save!
    remove_from_cache!
  end
end

# == Schema Information
#
# Table name: themes
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  user_id          :integer          not null
#  key              :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  compiler_version :integer          default(0), not null
#  user_selectable  :boolean          default(FALSE), not null
#  hidden           :boolean          default(FALSE), not null
#  color_scheme_id  :integer
#
# Indexes
#
#  index_themes_on_key  (key)
#
