class User < ActiveRecord::Base
  super_list :gender, 'Gender'
  super_list :gender1, 'Gender', :allow_blank => false
end
