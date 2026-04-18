class SettingsController < ApplicationController
  def show
    @setting = Setting.find_by(active: true)
  end
end
