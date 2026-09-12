class AttendanceRequestsController < ApplicationController
  def new
    @attendance_request = AttendanceRequest.new
  end


  def create
    # 申請内容をセット
    @attendance_request = AttendanceRequest.new(attendance_request_params)

    # 申請対象の日時と勤怠日を確認してセット
    set_attendance
    @attendance_request.attendance = @attendance

    # 申請日時を設定して、内容の保存
    @attendance_request.requested_at = Time.current
    @attendance_request.save!

    redirect_to attendances_path, notice: "申請を送信しました"
  end


  #################### private処理 ########################
  private

  def attendance_request_params
    params.require(:attendance_request).permit(:target_date, :requested_start_time, :requested_end_time, :requested_break_minutes, :reason)
  end

  def set_attendance
    @attendance = Attendance.find_by(work_date: attendance_request_params[:target_date])
  end
end
