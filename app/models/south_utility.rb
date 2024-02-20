class SouthUtility < Utility
  attr_reader :short_content_length, :medium_content_length

  after_initialize :after_initialize

  def after_initialize
    @short_content_length = 60
    @medium_content_length = 120
  end
end
