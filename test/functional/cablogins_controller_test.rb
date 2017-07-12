require File.dirname(__FILE__) + '/../test_helper'
require 'cablogins_controller'

# Re-raise errors caught by the controller.
class CabloginsController; def rescue_action(e) raise e end; end

class CabloginsControllerTest < Test::Unit::TestCase
  def setup
    @controller = CabloginsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
