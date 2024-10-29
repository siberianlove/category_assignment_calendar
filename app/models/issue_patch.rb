require_dependency 'issue'
module IssuePatch
  def self.included(base)
    base.class_eval do

      def default_assign
        if assigned_to.nil?
          if category && category.category_assignment_calendars
            user = category.category_assignment_calendars
                           .select { |c| c.is_active? }
                           .select { |c| c.occurs_now? }
                           .sort_by { |c| c.id }
                           .first
            unless user.nil?
              self.assigned_to = user.user
            end
          end
          if assigned_to.nil?
            if category && category.assigned_to
              self.assigned_to = category.assigned_to
            elsif project && project.default_assigned_to
              self.assigned_to = project.default_assigned_to
            end
          end
        end
      end
    end
  end
end