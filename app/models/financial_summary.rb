class FinancialSummary

  def initialize(attrs={})
    @attrs = attrs
    @current_user = User.find @attrs[:user_id]
    @currency = @attrs[:currency]
  end

  def one_day
    @current_user.transactions.where("created_at > ?", Time.now-1.days)
  end

  def seven_days
    @current_user.transactions.where("created_at > ?", Time.now-7.days)
  end

  def lifetime
    @current_user.transactions
  end

end
