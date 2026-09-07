# frozen_string_literal: true

RSpec.describe "Revealing anonymous users" do
  fab!(:master, :user)
  fab!(:anonymous_user) do
    Fabricate(:anonymous).tap do |shadow|
      shadow.anonymous_user_master.update!(master_user_id: master.id)
      shadow.reload
    end
  end
  fab!(:moderator)
  fab!(:user)

  before { SiteSetting.reveal_anonymous_enabled = true }

  it "shows staff the real account on the anonymous user's profile" do
    sign_in(moderator)
    visit "/u/#{anonymous_user.username}"

    expect(page).to have_css(
      "a.anon-user-identity[href='/u/#{master.username}']",
      text: master.username,
    )
  end

  it "shows regular users nothing" do
    sign_in(user)
    visit "/u/#{anonymous_user.username}"

    expect(page).to have_css(".user-profile-names__primary")
    expect(page).to have_no_css(".anon-user-identity")
  end
end
