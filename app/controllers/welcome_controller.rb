class WelcomeController < ApplicationController
  def index
    @todays_weight = WeightEntry.from(Date.today)

    # If they need to put one in
    @weight_entry = WeightEntry.new
  end
end
