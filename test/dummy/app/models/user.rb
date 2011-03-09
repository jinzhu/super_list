class User < ActiveRecord::Base
  super_list :gender, 'Gender'
  super_list :gender1, 'Gender', :allow_blank => false, :use_i18n => true
  super_list :gender2, 'Gender', :use_i18n => true, :i18n_default => '未知'
  super_list :gender3, 'Gender', :use_i18n => true, :i18n_default => '未知', :no_validation => true
end
