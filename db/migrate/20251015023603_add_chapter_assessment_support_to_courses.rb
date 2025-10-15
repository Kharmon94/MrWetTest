class AddChapterAssessmentSupportToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :time_managed, :boolean
    add_column :courses, :chapter_assessments_required, :boolean
  end
end
