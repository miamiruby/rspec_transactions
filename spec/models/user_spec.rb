require 'rails_helper'

describe User do
  it 'requires a valid email' do
    expect(User.new(email: nil).valid?).to eq(false)
    expect(User.new(email: '').valid?).to eq(false)
    expect(User.new(email: 'foo@').valid?).to eq(false)
    expect(User.new(email: 'foo@example.org').valid?).to eq(true)
  end

  it "should have many wallets" do
    user = User.reflect_on_association(:wallets)
    expect(user.macro).to eq(:has_many)
  end
end
