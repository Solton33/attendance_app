class SettingsController < ApplicationController
  before_action :set_setting

  def show
  end

  def update
    begin
      ActiveRecord::Base.transaction do
        # ① 今のactiveを全部inactiveにする
        Setting.where(active: true).update_all(active: false)

        # ② 新しい設定を作る
        Setting.create!(
          default_start_time: params[:setting][:default_start_time],
          default_end_time: params[:setting][:default_end_time],
          break_time: params[:setting][:break_time],
          active: true
        )
      end

      flash[:notice] = "設定を保存しました"
      redirect_to setting_path

    rescue => e
      flash[:alert] = "設定の保存に失敗しました"
      redirect_to setting_path
    end
  end


  #################### private処理 ########################
  #
  private

    def set_setting
      @setting = Setting.find_by(active: true)

      if @setting.nil?
        @setting = Setting.create!(
          break_time: 0,
          active: true
        )
      end
    end
end
