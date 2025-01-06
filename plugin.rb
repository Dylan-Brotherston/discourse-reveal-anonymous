# frozen_string_literal: true

# name: discourse-reveal-anonymous
# about: Allows moderators to identify who anonymous posters are.
# version: 2.0
# authors: Dylan Brotherston
# url: https://github.com/Dylan-Brotherston/discourse-reveal-anonymous

enabled_site_setting :reveal_anonymous_enabled

def add_to_serializer_staffonly(serializer, attr, define_include_method = true, &block)
  reloadable_patch do |plugin|
    base = "#{serializer.to_s.classify}Serializer".constantize rescue "#{serializer.to_s}Serializer".constantize

    ([base] + base.descendants).each do |klass|
      unless attr.to_s.start_with?("include_")
        klass.staff_attributes(attr)
      end
      klass.public_send(:define_method, attr, &block)
    end
  end
end

register_asset 'stylesheets/anonymous-users.scss'

after_initialize do
  add_to_serializer_staffonly :user_card, :master_user do
    UserCardSerializer.new(object.master_user, scope: scope, root: false) if SiteSetting.reveal_anonymous_enabled
  end
end
