require "virtus"
require "active_model"

module Gyroscope
  class SearchBase
    class ValidationError < StandardError
      attr_reader :searcher

      def initialize(searcher)
        @searcher = searcher
      end

      def message
        "Check your default values for correctness"
      end

      def as_json(*)
        { errors: searcher.errors }
      end
    end

    include Virtus.model strict: true, required: false
    include ActiveModel::Validations

    attribute :page,     Integer, default: 1
    attribute :per_page, Integer, default: 30
    attribute :order,    String

    validate :validate_order

    def initialize(attrs)
      super(normalize_order(attrs.dup))
    end

    def target_model
      "::#{self.class.name.demodulize}".constantize
    end

    def search
      # is there a more generic ActiveModel validation error?
      unless valid?
        Rails.logger.debug("the errors: #{errors.inspect}")

        fail ValidationError.new(self)
      end

      build_search_scope
    end

    private

    def normalize_order(attrs)
      order = attrs[:order] || attrs["order"]

      return attrs unless order.present?

      if order.is_a?(Hash)
        attrs[:order] = order.map {|(column, direction)| tablize_order("#{column} #{direction}")}.join(",")
      else
        attrs[:order] = tablize_order(order)
      end

      attrs
    end

    def tablize_order(ordering)
      unless /\./.match ordering
        "#{target_model.table_name}.#{ordering}"
      else
        ordering
      end
    end

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
      attributes[:order].split(",").each do |order|
        key, direction = order.split(' ')

        errors.add(:order, 'Ordering on disallowed key') unless allowed_order_keys.include? key
        errors.add(:order, 'Invalid sort direction') unless direction && %w(asc desc).include?(direction.downcase)
      end
    end

    def allowed_order_keys
      target_model.new.persistable_attribute_names.map do |key|
        "#{target_model.table_name}.#{key}"
      end
    end
  end
end
