class SuperList
  # I18n
  # SuperList.new("Gender", {"M" => "Man", "F" => "Female"}, :allow_blank => true)
  # super_list :gender, 'Gender'
  #
  # self.available_gender = ["M", "F"]
  # self.gender => 'Man'

  DEFAULT_OPTION = { :use_i18n => true }
  def initialize(name, values, options={})
  end
end
