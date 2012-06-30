# encoding=utf-8
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class SuperListTest < ActiveSupport::TestCase
  test "SuperList keys" do
    assert_equal SuperList["Gender"].keys, ["M","F"]
    assert_equal SuperList["Gender"].values, ["Man", "Female"]
    assert_equal SuperList["Gender1"].values(:locale => 'zh'),
      ["translation missing: zh.Gender1.Man", "translation missing: zh.Gender1.Female"]

		assert_equal SuperList["Gender"].get_value("M").to_s, "Man"
		assert_equal SuperList["Gender"].get_key("Man"), "M"
		assert_equal SuperList["Gender1"].get_key("translation missing: en.Gender1.Female"), "F"

    assert_equal ["M","F"], SuperList["Gender"].map {|k,v| k }
    assert_equal ["Man", "Female"], SuperList["Gender"].map {|k,v| v }

    assert_equal ["M","F"], SuperList["Gender"].select_options {|k,v| v }
    assert_equal ["Man", "Female"], SuperList["Gender"].select_options {|k,v| k }
  end

  test "only valid when included" do
    ## gender allow_blank => true
    assert FactoryGirl.build(:user).valid?
    assert FactoryGirl.build(:user, :gender => 'A').invalid?
    assert FactoryGirl.build(:user, :gender => 'MF').invalid?
    assert FactoryGirl.build(:user, :gender => 'M').valid?
    assert FactoryGirl.build(:user, :gender => 'F').valid?

    ## gender1 allow_blank => false
    assert FactoryGirl.build(:user, :gender1 => 'M').valid?
    assert FactoryGirl.build(:user, :gender1 => '').invalid?
  end

  test "set value" do
    user = FactoryGirl.build(:user, :gender => 'Man')
    assert user.valid?
    assert_equal user.gender(:amos), 'M1'
    user = FactoryGirl.build(:user, :gender => 'NoValue')
    assert user.invalid?
  end

  test "no validations for gender2" do
    assert FactoryGirl.build(:user, :gender3 => 'A').valid?
    assert FactoryGirl.build(:user, :gender3 => 'M').valid?
  end

  test "SuperList gender (don't use i18n)" do
    u = FactoryGirl.create(:user, :gender => 'F')
    assert_equal u.gender, 'F'
    assert_equal u.gender(:default), 'Female'
    assert_equal u.gender(:amos), 'M2'
  end

  test "SuperList gender (use i18n, no default translation)" do
    u = FactoryGirl.create(:user, :gender1 => 'F')
    assert_equal u.gender1(:default), "translation missing: en.Gender.Female"
    assert_equal u.gender1(:default, :locale => 'new_locale'), "translation missing: new_locale.Gender.Female"
    assert_equal u.gender1(:amos, :locale => 'new_locale'), "translation missing: new_locale.Gender.M2"
  end

  test "SuperList gender (use i18n wtih default translation)" do
    u = FactoryGirl.create(:user, :gender2 => 'F')
    assert_equal u.gender2, "F"
    assert_equal u.gender2(:nokey), "未知"
  end

  test "global options" do
    user = FactoryGirl.create(:user, :gender => 'Man')
    SuperList.options = {:format => :amos}
    assert_equal user.gender, 'M1'
    SuperList.options = {:format => :default}
    assert_equal user.gender, 'Man'
    SuperList.options = {}
  end
end
