# frozen_string_literal: true

RSpec.describe "Revealing anonymous users" do
  fab!(:master, :user)
  fab!(:anonymous_user) do
    Fabricate(:anonymous).tap do |shadow|
      shadow.anonymous_user_master.update!(master_user_id: master.id)
      shadow.reload
    end
  end
  fab!(:admin)
  fab!(:moderator)
  fab!(:user)

  before { SiteSetting.reveal_anonymous_enabled = true }

  def card_for(target)
    get "/u/#{target.username}/card.json"
    expect(response.status).to eq(200)
    response.parsed_body["user"]
  end

  def profile_for(target)
    get "/u/#{target.username}.json"
    expect(response.status).to eq(200)
    response.parsed_body["user"]
  end

  describe "user card" do
    it "reveals the real account to moderators" do
      sign_in(moderator)

      expect(card_for(anonymous_user).dig("master_user", "username")).to eq(master.username)
    end

    it "reveals the real account to admins" do
      sign_in(admin)

      expect(card_for(anonymous_user).dig("master_user", "username")).to eq(master.username)
    end

    it "only exposes basic public fields of the real account" do
      sign_in(admin)

      master_user = card_for(anonymous_user)["master_user"]

      expect(master_user["id"]).to eq(master.id)
      expect(master_user.keys).to include("username", "avatar_template")
      expect(master_user.keys).not_to include("email", "badge_count", "groups", "can_be_deleted")
    end

    it "is hidden from regular users" do
      sign_in(user)

      expect(card_for(anonymous_user)).not_to have_key("master_user")
    end

    it "is hidden from logged-out visitors" do
      expect(card_for(anonymous_user)).not_to have_key("master_user")
    end

    it "is hidden from the anonymous user themselves" do
      sign_in(anonymous_user)

      expect(card_for(anonymous_user)).not_to have_key("master_user")
    end

    it "is omitted for users who are not anonymous" do
      sign_in(admin)

      expect(card_for(user)).not_to have_key("master_user")
    end

    it "is hidden when the plugin is disabled" do
      SiteSetting.reveal_anonymous_enabled = false
      sign_in(admin)

      expect(card_for(anonymous_user)).not_to have_key("master_user")
    end
  end

  describe "user profile" do
    it "reveals the real account to staff" do
      sign_in(moderator)

      expect(profile_for(anonymous_user).dig("master_user", "username")).to eq(master.username)
    end

    it "is hidden from regular users" do
      sign_in(user)

      expect(profile_for(anonymous_user)).not_to have_key("master_user")
    end
  end

  describe "webhook payloads" do
    it "never include the real account" do
      payload = JSON.parse(WebHook.generate_payload(:user, anonymous_user.reload))

      expect(payload["username"]).to eq(anonymous_user.username)
      expect(payload).not_to have_key("master_user")
    end
  end
end
