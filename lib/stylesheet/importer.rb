require 'sassc'

module Stylesheet
  class Importer < SassC::Importer

    @special_imports = {}

    def self.special_imports
      @special_imports
    end

    def self.register_import(name, &blk)
      @special_imports[name] = blk
    end

    def self.import_files(files)
      files.map do |file|
        # we never want inline css imports, they are a mess
        # this tricks libsass so it imports inline instead
        if file =~ /\.css$/
          file = file[0..-5]
        end
        Import.new(file)
      end
    end

    register_import "plugins" do
      import_files(DiscoursePluginRegistry.stylesheets)
    end

    register_import "plugins_mobile" do
      import_files(DiscoursePluginRegistry.mobile_stylesheets)
    end

    register_import "plugins_desktop" do
      import_files(DiscoursePluginRegistry.desktop_stylesheets)
    end

    register_import "plugins_variables" do
      import_files(DiscoursePluginRegistry.sass_variables)
    end

    register_import "theme_variables" do
      contents = ""
      ColorScheme.base_colors.each do |n, base_hex|
        hex_val = ColorScheme.hex_for_name(n) || base_hex
        contents << "$#{n}: ##{hex_val} !default;\n"
      end

      Import.new("theme_variable.scss", source: contents)
    end

    register_import "category_backgrounds" do
      contents = ""
      Category.where('uploaded_background_id IS NOT NULL').each do |c|
        contents << category_css(c) if c.uploaded_background
      end

      Import.new("categoy_background.scss", source: contents)
    end

    register_import "embedded_theme" do
      return unless @theme_id

      theme_import("embedded_theme.scss", :embedded_scss)
    end

    register_import "mobile_theme" do
      return unless @theme_id

      [
        theme_import("common_theme.scss", :common_scss),
        theme_import("mobile_theme.scss", :mobile_scss)
      ].compact
    end

    register_import "desktop_theme" do
      return unless @theme_id

      [
        theme_import("common_theme.scss", :common_scss),
        theme_import("desktop_theme.scss", :desktop_scss)
      ].compact
    end

    def initialize(options)
      @theme_id = options[:theme_id]
    end

    def theme_import(name, attr)
      scss = theme.resolve_attr(attr)

      if scss.blank?
        nil
      else
        Import.new(name, source: scss)
      end
    end

    def theme
      @theme ||= Theme.find(@theme_id)
    end

    def apply_cdn(url)
      "#{GlobalSetting.cdn_url}#{url}"
    end

    def category_css(category)
      "body.category-#{category.full_slug} { background-image: url(#{apply_cdn(category.uploaded_background.url)}) }\n"
    end

    def imports(asset, parent_path)
      if asset[-1] == "*"
        Dir["#{Stylesheet::ASSET_ROOT}/#{asset}.scss"].map do |path|
          Import.new(asset[0..-2] + File.basename(path, ".*"))
        end
      elsif callback = Importer.special_imports[asset]
        callback.bind(self).call
      else
        Import.new(asset + ".scss")
      end
    end
  end
end
