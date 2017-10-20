require 'test_helper'

class IndicatorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @indicator = indicators(:one)
  end

  test "should get index" do
    get indicators_url
    assert_response :success
  end

  test "should get new" do
    get new_indicator_url
    assert_response :success
  end

  test "should create indicator" do
    assert_difference('Indicator.count') do
      post indicators_url, params: { indicator: { code: @indicator.code, description: @indicator.description, result_id: @indicator.result_id } }
    end

    assert_redirected_to indicator_url(Indicator.last)
  end

  test "should show indicator" do
    get indicator_url(@indicator)
    assert_response :success
  end

  test "should get edit" do
    get edit_indicator_url(@indicator)
    assert_response :success
  end

  test "should update indicator" do
    patch indicator_url(@indicator), params: { indicator: { code: @indicator.code, description: @indicator.description, result_id: @indicator.result_id } }
    assert_redirected_to indicator_url(@indicator)
  end

  test "should destroy indicator" do
    assert_difference('Indicator.count', -1) do
      delete indicator_url(@indicator)
    end

    assert_redirected_to indicators_url
  end
end
