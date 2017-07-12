require File.dirname(__FILE__) + '/../test_helper'
require 'cabvuelos_controller'

# Re-raise errors caught by the controller.
class CabvuelosController; def rescue_action(e) raise e end; end

class CabvuelosControllerTest < Test::Unit::TestCase
  def setup
    @controller = CabvuelosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
