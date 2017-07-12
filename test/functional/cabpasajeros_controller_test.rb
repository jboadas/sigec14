require File.dirname(__FILE__) + '/../test_helper'
require 'cabpasajeros_controller'

# Re-raise errors caught by the controller.
class CabpasajerosController; def rescue_action(e) raise e end; end

class CabpasajerosControllerTest < Test::Unit::TestCase
  def setup
    @controller = CabpasajerosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
