require "test_helper"

class BookingSystemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get booking_systems_index_url
    assert_response :success
  end
end
