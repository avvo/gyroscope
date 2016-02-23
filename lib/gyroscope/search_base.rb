require "virtus"
require "active_model"

module Gyroscope
  class SearchBase
    include Virtus.model strict: true, required: false
    include ActiveModel::Validations

    attribute :page,     Integer, default: 1
    attribute :per_page, Integer, default: 30
    attribute :order,    String

    validate :validate_order

    def initialize(*args)
      super(*args)
      normalize_order attributes[:order]
    end

    def target_model
      "::#{self.class.name.demodulize}".constantize
    end

    def search
      # is there a more generic ActiveModel validation error?
      unless valid?
        Rails.logger.debug("the errors: #{errors.inspect}")
      end
      fail ActiveModel::ForbiddenAttributesError, "Check your default values for correctness" unless valid?

      build_search_scope
    end

    def normalize_order(ordering)
      return unless attributes[:order]

      unless /\./.match ordering
        self.order = "#{target_model.table_name}.#{ordering}"
      else
        self.order = ordering
      end
    end

    private

    def base_scope
      scope = target_model

      if attributes[:page] || attributes[:per_page]
        scope = pagination_scope(scope)
      end
      if attributes[:order]
        scope = scope.order(attributes[:order])
      end

      scope
    end

    def pagination_scope(scope)
      pagination_scope            = {}
      pagination_scope[:page]     = attributes[:page] if attributes[:page]
      pagination_scope[:per_page] = attributes[:per_page] if attributes[:per_page]

      scope.paginate(pagination_scope)
    end

    def build_search_scope
      base_scope
    end

    def validate_order
      return unless attributes[:order]
      split_order = attributes[:order].split(' ')

      key, direction = split_order

      errors.add(:order, 'Ordering on disallowed key') unless allowed_order_keys.include? key
      errors.add(:order, 'Invalid sort direction') unless direction && %w(asc desc).include?(direction.downcase)
    end

    def allowed_order_keys
      target_model.new.attributes.keys.map do |key|
        "#{target_model.table_name}.#{key}"
      end
    end
  end
end
