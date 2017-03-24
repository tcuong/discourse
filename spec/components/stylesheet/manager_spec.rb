require 'rails_helper'
require 'stylesheet/compiler'

describe Stylesheet::Manager do
  it 'can correctly compile theme css' do
    theme = Theme.create!(
      name: 'parent',
      user_id: -1,
      common_scss: ".common{.scss{color: red;}}",
      desktop_scss: ".desktop{.scss{color: red;}}",
      mobile_scss: ".mobile{.scss{color: red;}}",
      embedded_scss: ".embedded{.scss{color: red;}}",
    )

    child_theme = Theme.create!(
      name: 'parent',
      user_id: -1,
      common_scss: ".child_common{.scss{color: red;}}",
      desktop_scss: ".child_desktop{.scss{color: red;}}",
      mobile_scss: ".child_mobile{.scss{color: red;}}",
      embedded_scss: ".child_embedded{.scss{color: red;}}",
    )

    theme.add_child_theme!(child_theme)

    old_link = Stylesheet::Manager.stylesheet_link_tag(:desktop_theme, 'all', theme.id)

    manager = Stylesheet::Manager.new(:desktop_theme, theme.id)
    manager.compile(force: true)

    css = File.read(manager.stylesheet_fullpath)
    _source_map = File.read(manager.source_map_fullpath)

    expect(css).to match(/child_common/)
    expect(css).to match(/child_desktop/)
    expect(css).to match(/\.common/)
    expect(css).to match(/\.desktop/)


    child_theme.desktop_scss = ".nothing{color: green;}"
    child_theme.save!

    new_link = Stylesheet::Manager.stylesheet_link_tag(:desktop_theme, 'all', theme.id)

    expect(new_link).not_to eq(old_link)
  end
end

