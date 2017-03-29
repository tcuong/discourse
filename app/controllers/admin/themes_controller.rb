class Admin::ThemesController < Admin::AdminController

  skip_before_filter :check_xhr, only: [:show]

  def index
    @theme = Theme.order(:name).includes(:theme_fields)

    respond_to do |format|
      format.json { render json: @theme }
    end
  end

  def create
    @theme = Theme.new(name: theme_params[:name], user_id: current_user.id)

    set_fields

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
    @theme.name = theme_params[:name]

    set_fields

    respond_to do |format|
      if @theme.save
        log_theme_change(@theme, theme_params)
        format.json { render json: @theme, status: :created}
      else
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
      @theme_params ||=
        params.require(:theme)
            .permit(:name, theme_fields: [:name, :target, :value])
    end

    def set_fields
      theme_params[:theme_fields].each do |field|
        @theme.set_field(field[:target], field[:name], field[:value])
      end
    end

    def log_theme_change(old_record, new_params)
      StaffActionLogger.new(current_user).log_theme_change(old_record, new_params)
    end

end
