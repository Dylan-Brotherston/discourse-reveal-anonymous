# frozen_string_literal: true

module DiscourseRevealAnonymous
  # `WebHookUserSerializer` inherits from `UserSerializer`, and webhook payloads
  # are serialized with a system-user scope that passes the staff check. This
  # keeps the real account out of every webhook payload.
  module WebHookUserSerializerExtension
    def include_master_user?
      false
    end
  end
end
