require 'rails_helper'

describe FinancialSummary do
  let!(:user) { create(:user) }

  # Feel free to change what the subject-block returns
  subject { FinancialSummary.new(user_id: user.id, currency: :usd) }

  it 'summarizes over one day' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))

      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(7.67, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5, :cad))
    end

    expect(subject.one_day.where(deposit: true).count).to eq(2)
    expect(subject.one_day.where(deposit: true).sum(:amount_cents)).to eq(1212)

    expect(subject.one_day.where(category: :purchase).count).to eq(1)
    expect(subject.one_day.where(category: :purchase).sum(:amount_cents)).to eq(767)

    expect(subject.one_day.where(category: :refund).count).to eq(1)
    expect(subject.one_day.where(category: :refund).sum(:amount_cents)).to eq(500)
  end

  it 'summarizes over seven days' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))
    end

    Timecop.travel(Time.now - 10.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(131, :usd))

      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(7.67, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5, :cad))
    end

    expect(subject.seven_days.where(deposit: true).count).to eq(2)
    expect(subject.seven_days.where(deposit: true).sum(:amount_cents)).to eq(1212)

    expect(subject.seven_days.where(category: :purchase).count).to eq(0)
    expect(subject.seven_days.where(category: :purchase).sum(:amount_cents)).to eq(0)

    expect(subject.seven_days.where(category: :refund).count).to eq(0)
    expect(subject.seven_days.where(category: :refund).sum(:amount_cents)).to eq(0)
  end

  it 'summarizes over lifetime' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))
    end

    Timecop.travel(Time.now - 30.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(131, :usd))

      create(:transaction, user: user,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(7.67, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5, :cad))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(13.45, :usd))
    end

    expect(subject.lifetime.where(deposit: true).count).to eq(2)
    expect(subject.lifetime.where(deposit: true).sum(:amount_cents)).to eq(1212)

    expect(subject.lifetime.where(category: :purchase).count).to eq(1)
    expect(subject.lifetime.where(category: :purchase).sum(:amount_cents)).to eq(13100)

    expect(subject.lifetime.where(category: :refund).count).to eq(2)
    expect(subject.lifetime.where(category: :refund).sum(:amount_cents)).to eq(1845)

    expect(subject.lifetime.where(category: :withdraw).count).to eq(1)
    expect(subject.lifetime.where(category: :withdraw).sum(:amount_cents)).to eq(767)

  end
end
