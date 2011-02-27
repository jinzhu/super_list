require 'test_helper'

class SuperListTest < ActiveSupport::TestCase
  test "SuperList" do
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
end
