class OngoingTaskBlueprint < Blueprinter::Base
  identifier :id
  fields :type, :params, :action_points_spent, :action_points_required, :repeatable
end
