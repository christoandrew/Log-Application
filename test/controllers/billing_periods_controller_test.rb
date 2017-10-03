require 'test_helper'

class BillingPeriodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @billing_period = billing_periods(:one)
  end

  test "should get index" do
    get billing_periods_url
    assert_response :success
  end

  test "should get new" do
    get new_billing_period_url
    assert_response :success
  end

  test "should create billing_period" do
    assert_difference('BillingPeriod.count') do
      post billing_periods_url, params: { billing_period: { end_date: @billing_period.end_date, start_date: @billing_period.start_date } }
    end

    assert_redirected_to billing_period_url(BillingPeriod.last)
  end

  test "should show billing_period" do
    get billing_period_url(@billing_period)
    assert_response :success
  end

  test "should get edit" do
    get edit_billing_period_url(@billing_period)
    assert_response :success
  end

  test "should update billing_period" do
    patch billing_period_url(@billing_period), params: { billing_period: { end_date: @billing_period.end_date, start_date: @billing_period.start_date } }
    assert_redirected_to billing_period_url(@billing_period)
  end

  test "should destroy billing_period" do
    assert_difference('BillingPeriod.count', -1) do
      delete billing_period_url(@billing_period)
    end

    assert_redirected_to billing_periods_url
  end
end
