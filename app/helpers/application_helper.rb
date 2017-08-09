module ApplicationHelper

  #引数に現在のコントローラーが含まれていたらtrueを返す
  def controller?(controller)
    controller.include?(params[:controller])
  end

  #引数に現在のコントローラーが含まれていたらtrueを返す
  def action?(action)
    action.include?(params[:action])
  end
end
