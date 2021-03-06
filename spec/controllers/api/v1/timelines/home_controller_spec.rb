# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Timelines::HomeController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice'), current_sign_in_at: 1.day.ago) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  context 'with a user context' do
    let(:token) { double acceptable?: true, resource_owner_id: user.id }

    describe 'GET #show' do
      before do
        follow = Fabricate(:follow, account: user.account)
        PostStatusService.new.call(follow.target_account, 'New status for user home timeline.')
      end

      it 'returns http success' do
        get :show

        expect(response).to have_http_status(:success)
        expect(response.headers['Link'].links.size).to eq(2)
      end
    end
  end

  context 'without a user context' do
    let(:token) { double acceptable?: true, resource_owner_id: nil }

    describe 'GET #show' do
      it 'returns http unprocessable entity' do
        get :show

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.headers['Link']).to be_nil
      end
    end
  end
end
