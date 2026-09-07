# frozen_string_literal: true

# name: discourse-reveal-anonymous
# about: Lets staff see the real account behind an anonymous user.
# version: 2.1
# authors: Dylan Brotherston
# url: https://github.com/Dylan-Brotherston/discourse-reveal-anonymous
# required_version: 2026.5.0

enabled_site_setting :reveal_anonymous_enabled

register_asset "stylesheets/anonymous-users.scss"

module ::DiscourseRevealAnonymous
  PLUGIN_NAME = "discourse-reveal-anonymous"
end

require_relative "lib/discourse_reveal_anonymous/web_hook_user_serializer_extension"

after_initialize do
  # Staff only, and only for users that actually have a master account, so
  # regular users never carry a `master_user` key at all. `UserSerializer`
  # (the profile) inherits from `UserCardSerializer`, so both get it.
  add_to_serializer(
    :user_card,
    :master_user,
    include_condition: -> { scope.is_staff? && object.master_user.present? },
  ) { BasicUserSerializer.new(object.master_user, scope: scope, root: false) }

  # Webhook payloads are built with a system-user scope, which counts as staff.
  # The real identity must never be sent to external endpoints.
  reloadable_patch do
    WebHookUserSerializer.prepend(DiscourseRevealAnonymous::WebHookUserSerializerExtension)
  end
end
