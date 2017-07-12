require File.dirname(__FILE__) + '/../test_helper'
require 'cabequipos_controller'

# Re-raise errors caught by the controller.
class CabequiposController; def rescue_action(e) raise e end; end

class CabequiposControllerTest < Test::Unit::TestCase
  def setup
    @controller = CabequiposController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
