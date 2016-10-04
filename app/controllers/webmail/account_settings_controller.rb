class Webmail::AccountSettingsController < ApplicationController
  include Webmail::BaseFilter
  include Webmail::ImapFilter
  include Sns::CrudFilter

  skip_action_callback :set_imap

  model SS::User

  menu_view "ss/crud/resource_menu"

  private
    def set_crumbs
      @crumbs << [:"webmail.account_setting", { action: :show } ]
    end

    def fix_params
      { self_edit: true }
    end

    def permit_fields
      [:imap_host, :imap_account, :in_imap_password]
    end

    def get_params
      para = super
      para.delete(:password) if para[:password].blank?
      para
    end

    def set_item
      @item = @cur_user
    end

  public
    def show
      # render
    end
end
