require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Setting.create!(active: true, break_time: 60)
  end

  test "should get index" do
    get attendances_index_url
    assert_response :success
  end
end
