require File.dirname(__FILE__) + '/../test_helper'
require 'user_mailer_controller'

# Re-raise errors caught by the controller.
class UserMailerController; def rescue_action(e) raise e end; end

class UserMailerControllerTest < Test::Unit::TestCase
  def setup
    @controller = UserMailerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
