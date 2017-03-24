class ThemeSerializer < ApplicationSerializer

  attributes :id, :name, :key, :created_at, :updated_at,
             :common_scss, :desktop_scss, :header, :footer, :top,
             :mobile_scss, :mobile_header, :mobile_footer, :mobile_top,
             :head_tag, :body_tag, :embedded_scss
end
