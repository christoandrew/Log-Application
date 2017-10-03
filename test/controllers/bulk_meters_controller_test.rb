require 'test_helper'

class BulkMetersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bulk_meter = bulk_meters(:one)
  end

  test "should get index" do
    get bulk_meters_url
    assert_response :success
  end

  test "should get new" do
    get new_bulk_meter_url
    assert_response :success
  end

  test "should create bulk_meter" do
    assert_difference('BulkMeter.count') do
      post bulk_meters_url, params: { bulk_meter: { location: @bulk_meter.location, meter_type: @bulk_meter.meter_type, serial_number: @bulk_meter.serial_number, size: @bulk_meter.size, sr: @bulk_meter.sr, town_id: @bulk_meter.town_id } }
    end

    assert_redirected_to bulk_meter_url(BulkMeter.last)
  end

  test "should show bulk_meter" do
    get bulk_meter_url(@bulk_meter)
    assert_response :success
  end

  test "should get edit" do
    get edit_bulk_meter_url(@bulk_meter)
    assert_response :success
  end

  test "should update bulk_meter" do
    patch bulk_meter_url(@bulk_meter), params: { bulk_meter: { location: @bulk_meter.location, meter_type: @bulk_meter.meter_type, serial_number: @bulk_meter.serial_number, size: @bulk_meter.size, sr: @bulk_meter.sr, town_id: @bulk_meter.town_id } }
    assert_redirected_to bulk_meter_url(@bulk_meter)
  end

  test "should destroy bulk_meter" do
    assert_difference('BulkMeter.count', -1) do
      delete bulk_meter_url(@bulk_meter)
    end

    assert_redirected_to bulk_meters_url
  end
end
