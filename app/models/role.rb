class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource, polymorphic: true, optional: true

  # Validate that resource_type, if provided, is one of Rolify’s resource types.
  validates :resource_type, inclusion: { in: Rolify.resource_types }, allow_nil: true

  # Validate presence of name.
  validates :name, presence: true

  scopify
end

