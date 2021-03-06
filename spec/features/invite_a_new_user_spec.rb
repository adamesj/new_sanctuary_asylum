require 'rails_helper'

RSpec.describe 'Admin invites a new user', type: :feature do

  let(:admin) { create(:user, :admin) }
  let(:email) { FFaker::Internet.email }

  describe 'admin inviting a new user' do
    before do 
      login_as(admin)
      visit new_user_invitation_path
      fill_in 'Email', with: email
    end

    it 'displays a message that the invitation was sent' do
      click_button 'Send an invitation'
      within '.alert' do
        expect(page).to have_content "An invitation email has been sent to #{email}."
      end
    end

    it 'sends the invitation' do
      expect{ click_button 'Send an invitation' }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  describe 'user accepting an invitation' do
    before do 
      login_as(admin)
      visit new_user_invitation_path
      fill_in 'Email', with: email
      click_button 'Send an invitation'
      confirmation_link = URI.extract(ActionMailer::Base.deliveries.last.text_part.body.to_s)[1]
      logout(admin)
      visit confirmation_link
    end

    describe 'with valid information' do
      it 'signs in the user' do
        fill_in 'First Name', with: FFaker::Name.first_name
        fill_in 'Last Name', with: FFaker::Name.last_name
        fill_in 'Phone', with: '876 765 4455'
        select 'English Speaking', :from => 'Type'
        fill_in 'Password', with: 'Password1234'
        fill_in 'Password Confirmation', with: 'Password1234'
        check 'user_pledge_signed'
        click_button 'Save'

        expect(page).to have_content('Your password was set successfully. You are now signed in.')
        expect(current_path).to eq(dashboard_path) 
      end
    end

    describe 'with invalid information' do
      it 'displays validation errors' do
        click_button 'Save'
        expect(page).to have_content("First name can't be blank")
      end

      it 'does not sign in the user' do
        click_button 'Save'
        expect(page).not_to have_content('Your password was set successfully. You are now signed in.')
      end
    end
  end  
end