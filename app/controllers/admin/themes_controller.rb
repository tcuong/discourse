class Admin::ThemesController < Admin::AdminController

  before_filter :enable_theme

  skip_before_filter :check_xhr, only: [:show]

  def index
    @theme = Theme.order(:name)

    respond_to do |format|
      format.json { render json: @theme }
    end
  end

  def create
    @theme = Theme.new(theme_params)
    @theme.user_id = current_user.id

    respond_to do |format|
      if @theme.save
        log_theme_change(nil, theme_params)
        format.json { render json: @theme, status: :created}
      else
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @theme = Theme.find(params[:id])
    log_record = log_theme_change(@theme, theme_params)

    respond_to do |format|
      if @theme.update_attributes(theme_params)
        format.json { render json: @theme, status: :created}
      else
        log_record.destroy if log_record
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @theme = Theme.find(params[:id])
    StaffActionLogger.new(current_user).log_theme_destroy(@theme)
    @theme.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def show
    @theme = Theme.find(params[:id])

    respond_to do |format|
      format.json do
        check_xhr
        render json: ThemeSerializer.new(@theme)
      end

      format.any(:html, :text) do
        raise RenderEmpty.new if request.xhr?

        response.headers['Content-Disposition'] = "attachment; filename=#{@theme.name.parameterize}.dcstyle.json"
        response.sending_file = true
        render json: ThemeSerializer.new(@theme)
      end
    end

  end

  private

    def theme_params
      params.require(:theme)
            .permit(:name, :desktop_scss, :mobile_scss, :common_scss, :header, :top, :footer,
                    :mobile_header, :mobile_top, :mobile_footer,
                    :head_tag, :body_tag,
                    :position, :key, :embedded_scss)
    end

    def log_theme_change(old_record, new_params)
      StaffActionLogger.new(current_user).log_theme_change(old_record, new_params)
    end

    def enable_theme
      session[:disable_customization] = false
    end

end
