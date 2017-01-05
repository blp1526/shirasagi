class Sns::PublicNoticesController < ApplicationController
  include Sys::BaseFilter
  include Sys::CrudFilter
  include Sns::PublicNoticeFilter

  skip_before_action :logged_in?, only: [:index, :show]

  layout "ss/login"
  navi_view nil

  private
    def set_crumbs
      @crumbs = []
    end
end