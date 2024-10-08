# spec/plugin_spec.rb

require 'rails_helper'

describe 'LastDayUsedKey Plugin' do
  let(:user) { Fabricate(:user) }
  let(:user_api_key) { Fabricate(:user_api_key, user: user) }
  let(:api_key) { Fabricate(:api_key, user: user) }

  before do
    SiteSetting.discourse_plugin_markdown_html_whitelist_enabled = true
  end

  describe '#update_last_used for UserApiKey' do
    it 'updates last_used_at to beginning of the day if not already set' do
      user_api_key.update!(last_used_at: 2.days.ago)

      expect {
        user_api_key.update_last_used("client_id_1")
      }.to change { user_api_key.reload.last_used_at }
         .to(Time.zone.now.beginning_of_day)
    end

    it 'does not update last_used_at if already set to beginning of the day' do
      user_api_key.update!(last_used_at: Time.zone.now.beginning_of_day)

      expect {
        user_api_key.update_last_used("client_id_1")
      }.not_to change { user_api_key.reload.last_used_at }
    end

    it 'updates client_id and destroys other keys with same client_id and user_id' do
      Fabricate(:user_api_key, user: user, client_id: "client_id_1")

      expect {
        user_api_key.update_last_used("client_id_1")
      }.to change { user_api_key.reload.client_id }.to("client_id_1")
      expect(UserApiKey.where(client_id: "client_id_1", user_id: user.id).count).to eq(1)
    end
  end

  describe '#update_last_used! for ApiKey' do
    it 'updates last_used_at to beginning of the day if not already set' do
      api_key.update!(last_used_at: 2.days.ago)

      expect {
        api_key.update_last_used!
      }.to change { api_key.reload.last_used_at }
         .to(Time.zone.now.beginning_of_day)
    end

    it 'does not update last_used_at if already set to beginning of the day' do
      api_key.update!(last_used_at: Time.zone.now.beginning_of_day)

      expect {
        api_key.update_last_used!
      }.not_to change { api_key.reload.last_used_at }
    end
  end
end
