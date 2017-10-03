require 'test_helper'

class MeterReadersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meter_reader = meter_readers(:one)
  end

  test "should get index" do
    get meter_readers_url
    assert_response :success
  end

  test "should get new" do
    get new_meter_reader_url
    assert_response :success
  end

  test "should create meter_reader" do
    assert_difference('MeterReader.count') do
      post meter_readers_url, params: {meter_reader: {email: @meter_reader.email, name: @meter_reader.name, password: @meter_reader.password, username: @meter_reader.username}}
    end

    assert_redirected_to meter_reader_url(MeterReader.last)
  end

  test "should show meter_reader" do
    get meter_reader_url(@meter_reader)
    assert_response :success
  end

  test "should get edit" do
    get edit_meter_reader_url(@meter_reader)
    assert_response :success
  end

  test "should update meter_reader" do
    patch meter_reader_url(@meter_reader), params: {meter_reader: {email: @meter_reader.email, name: @meter_reader.name, password: @meter_reader.password, username: @meter_reader.username}}
    assert_redirected_to meter_reader_url(@meter_reader)
  end

  test "should destroy meter_reader" do
    assert_difference('MeterReader.count', -1) do
      delete meter_reader_url(@meter_reader)
    end

    assert_redirected_to meter_readers_url
  end
end
