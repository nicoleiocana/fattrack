require 'test_helper'

class WeightEntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "associates weight entries with the current user" do
    user = User.create(email: 'auser@example.com', password: 'password')
    sign_in user

    post weight_entries_url, params: {weight_entry: {value: 150}}

    assert_equal 1, user.weight_entries.count
    new_entry = user.weight_entries.first
    assert_equal 150, new_entry.value
  end

  test "shows all entries on index, sorted" do
    Timecop.freeze('2018-08-14'.to_time) do
      user = User.create(email: 'auser@example.com', password: 'password')
      WeightEntry.destroy_all
      WeightEntry.create(user: user, value: 126, day: 2.days.ago)
      WeightEntry.create(user: user, value: 124, day: 0.days.ago)
      WeightEntry.create(user: user, value: 127, day: 3.days.ago)
      WeightEntry.create(user: user, value: 125, day: 1.days.ago)
      sign_in user

      get "#{weight_entries_url}.json"

      json = JSON.parse(response.body)

      assert_equal [
        {"created_at" => "2018-08-14T04:00:00.000Z", "value" => "124"},
        {"created_at" => "2018-08-13T04:00:00.000Z", "value" => "125"},
        {"created_at" => "2018-08-12T04:00:00.000Z", "value" => "126"},
        {"created_at" => "2018-08-11T04:00:00.000Z", "value" => "127"},
      ], json
      # rows = css_select ".weight_entry"
      # row = ->(n) { css_select(rows[n], 'td').map(&:text) }
      # assert_equal ['Today', '124 lbs'], row[0]
      # assert_equal ['Yesterday', '125 lbs'], row[1]
      # assert_equal ['Sunday', '126 lbs'], row[2]
      # assert_equal ['Saturday', '127 lbs'], row[3]
    end
  end

  test "only shows entries for the current user" do
    user_a = User.create(email: 'user_a@example.com', password: 'password')
    user_b = User.create(email: 'user_b@example.com', password: 'password')
    3.times { WeightEntry.create(user: user_a, value: 100, day: Time.now) }
    2.times { WeightEntry.create(user: user_b, value: 100, day: Time.now) }
    sign_in user_a

    get weight_entries_url

    assert_select '.weight_entry', 3
  end
end
