require 'test_helper'

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
  end

  test "only valid when included" do
    ## gender allow_blank => true
    assert Factory.build(:user).valid?
    assert !Factory.build(:user, :gender => 'A').valid?
    assert !Factory.build(:user, :gender => 'MF').valid?
    assert Factory.build(:user, :gender => 'M').valid?
    assert Factory.build(:user, :gender => 'F').valid?

    ## gender1 allow_blank => false
    assert Factory.build(:user, :gender1 => 'M').valid?
    assert !Factory.build(:user, :gender1 => '').valid?
  end

  test "SuperList gender (don't use i18n)" do
    u = Factory(:user, :gender => 'F')
    assert_equal u.gender.to_s, 'Female'
    assert_equal u.gender.to_s(:amos), 'M2'
  end

  test "SuperList gender (use i18n, no default translation)" do
    u = Factory(:user, :gender1 => 'F')
    assert_equal u.gender1.to_s, "translation missing: en.Gender.Female"
    assert_equal u.gender1(:locale => 'new_locale').to_s, "translation missing: new_locale.Gender.Female"
    assert_equal u.gender1(:locale => 'new_locale').to_s(:amos), "translation missing: new_locale.Gender.M2"
  end

  test "SuperList gender (use i18n wtih default translation)" do
    u = Factory(:user, :gender2 => 'F')
    assert_equal u.gender2.to_s, "未知"
    assert_equal u.gender2.to_s(:nokey), "未知"
  end
end
