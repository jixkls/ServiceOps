module Authorization
  extend ActiveSupport::Concern

  class NotAuthorized < StandardError; end

  included do
    rescue_from NotAuthorized, with: :deny_access
  end

  private
    def require_role!(*roles)
      raise NotAuthorized unless Current.user&.role&.in?(roles.map(&:to_s))
    end

    def authorize_service_order!(service_order)
      return if Current.user.admin? || Current.user.attendant?
      return if Current.user.technician? && service_order.assigned_user_id == Current.user.id

      raise NotAuthorized
    end

    def deny_access
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Você não tem permissão para realizar esta ação." }
        format.json { render json: { error: "Acesso não autorizado" }, status: :forbidden }
      end
    end
end
