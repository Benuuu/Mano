require 'test_helper'
require 'helpers/authorizations_helper'

class AuthorizationsControllerTest < ActionController::TestCase
  include AuthorizationsTestHelper
  setup :activate_authlogic


  setup do
    @fb_auth = FactoryGirl.create :facebook_auth
    @ig_auth = FactoryGirl.create :instagram_auth
    @foursquare_auth = FactoryGirl.create :foursquare_auth
    @twitter_auth = FactoryGirl.create :twitter_auth
    @google_auth = FactoryGirl.create :google_auth
    @user = @fb_auth.user
    @session = UserSession.create(@user)

  end

  test "should FB redirect to correct url" do
    check_correct_url("facebook",@fb_auth)
  end

  test "Should Handle FB Callback" do
    @fb_auth_authorized = FactoryGirl.create :fb_auth_complete

    VCR.use_cassette('facebook/auth_callback') do
      get :callback, :provider => "facebook",:code=> "AQBtxU2YfKf0J0iQtRMwLae5X5vcZdZuvr3L-hjTyJHKk0rtSwOmd3Xzo2y06DlXdA7hpwx1uUJ-9coOz5aIbJwy9WCTBkvftQLTp9-4vrnSo21xlA1Vy7gBZOX-z1s2DU5jSgk27uavqYb3H1Ts4jM6UEcdHUCWjQdSRKdsArdaLAZn4k2H7XAmP7XzAaXt7qmv5exvqMzVAegzBryE8Q_9TSnzCR87UXm3oHeKIB_CYcwobxDrmcdNnNi-sP_5-8aE8M-JvDV9j2itPNL5Upbjfd7rIiCDaptZ-ZuQPDh7XAVMMIF0U-xUk0KkOC4Pqlc"
      received_auth = assigns("authorization")
      assert_equal @fb_auth_authorized.auth_token, received_auth.auth_token, "Check Auth Token is Correct"
      assert_instance_of FacebookAuth, received_auth, "Check returned auth is a FB auth"
    end
  end

  test "should Instagram redirect to correct url" do
    check_correct_url("instagram",@ig_auth)
  end

  test "Should Handle Instagram Callback" do
     @ig_auth_authorized = FactoryGirl.create :ig_auth_complete

    VCR.use_cassette('instagram/auth_callback') do
      get :callback, :provider => "instagram",:code=> "eb9e7974fb02478ba8dfa84a58a57532"
      received_auth = assigns("authorization")
      assert_equal @ig_auth_authorized.auth_token, received_auth.auth_token, "Check Auth Token is Correct"
      assert_instance_of InstagramAuth, received_auth, "Check returned auth is a FB auth"
    end
  end
  
  test "should Foursquare redirect to correct url" do
    check_correct_url("foursquare",@foursquare_auth)
  end

  test "Should Handle Foursquare Callback" do
     @foursquare_auth_authorized = FactoryGirl.create :foursquare_auth_complete

    VCR.use_cassette('foursquare/auth_callback') do
      get :callback, :provider => "foursquare",:code=> "IU5H4OUIAVLJJ5Z4PYKDX0SFQKQMXTVT4GCSM55S4TMV1YRY"
      received_auth = assigns("authorization")
      assert_equal @foursquare_auth_authorized.auth_token, received_auth.auth_token, "Check Auth Token is Correct"
      assert_instance_of FoursquareAuth, received_auth, "Check returned auth is a Foursquare auth"
    end
  end

  test "should Twitter redirect to correct url" do
    # Allow playback repeats because Twitter_Auth hits server to get unique
    # access_url. I want the functionality to be identical given the same 
    # response from Twitter.
    
    VCR.use_cassette("twitter/access_url", :allow_playback_repeats => true) do
      check_correct_url("twitter",@twitter_auth)
    end
  end

  test "Should Handle Twitter Callback" do
     @twitter_auth_authorized = FactoryGirl.create :twitter_auth_complete

    VCR.use_cassette('twitter/auth_callback') do
      @request.session["request_token"] = "0TghjHAUMDgDcqM6dH2PwlWM299I2Mjbzkm5LTbFEtU"
      @request.session["request_secret"] = "Xvz6JdLNmbWRunMQz04Fn4VQYOLr5opXwZWKussM"
      get(:callback, :provider => "twitter",
          "oauth_token"=>"0TghjHAUMDgDcqM6dH2PwlWM299I2Mjbzkm5LTbFEtU", 
          "oauth_verifier"=>"PaFpWDliZ7aoAhfn1zpLfKwyZrBNGsstkZcq9QuZbwo")
      received_auth = assigns("authorization")
      assert_equal @twitter_auth_authorized.auth_token, received_auth.auth_token, "Check Auth Token is Correct"
      assert_instance_of TwitterAuth, received_auth, "Check returned auth is a Twitter auth"
    end
  end


  test "should Google redirect to correct url" do
    check_correct_url("google",@google_auth)
  end

  test "Should Handle Google Callback" do
     @google_auth_authorized = FactoryGirl.create :google_auth_complete

    VCR.use_cassette('google/auth_callback') do
      get :callback, :provider => "google",:code=> "4/WLsBLvLWgqB1FtMJpRkNpoDq2L9c.8vBDqH8jXeYTmmS0T3UFEsPcuzTmfQI"
      received_auth = assigns("authorization")
      assert_equal @google_auth_authorized.auth_token, received_auth.auth_token, "Check Auth Token is Correct"
      assert_equal @google_auth_authorized.refresh_token, received_auth.refresh_token, "Check Refresh Token is Correct"
      # assert_equal @google_auth_authorized.expires_at, received_auth.expires_at, "Check Expires At is Correct"
      assert_instance_of GoogleAuth, received_auth, "Check returned auth is a Google auth"
    end
  end
  
  test "Should Destroy Authorization" do
    assert_difference("Authorization.count",-1, "Check delete actually works") do
      delete :destroy, id: @fb_auth
    end

    assert_redirected_to authorizations_path, "Check Delete Redirect"
  end

  test "Should List Authorizations" do
    get :index
    assert_response :success, "Check Index Response is success"
    assert_includes assigns("authorizations"), @fb_auth, "Check index response has fb_auth"
  end



end
