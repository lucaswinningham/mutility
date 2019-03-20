require 'mutility/engine'

module Mutility
  extend ActiveSupport::Concern

  included do
    around_save :mutilitize_around_save
  end

  module ClassMethods
    attr_reader :mutilize_attrs
    attr_reader :mutilize_kwargs
    attr_reader :mutilize_change_model
    attr_reader :mutilize_reference_sym
    attr_reader :mutilize_columns_map

    private

    def mutilize(*attrs, **kwargs)
      @mutilize_attrs = attrs || []
      @mutilize_kwargs = kwargs
      mutilize_assign_change_model
      mutilize_assign_reference_sym
      mutilize_assign_columns_map
    end

    def mutilize_assign_change_model
      @mutilize_change_model = mutilize_kwargs[:change_model] || "#{name}Change".constantize
    end

    def mutilize_assign_reference_sym
      @mutilize_reference_sym = name.to_s.underscore.to_sym
    end

    def mutilize_assign_columns_map
      unless mutilize_kwargs[:map_columns]
        @mutilize_columns_map = mutilize_attrs.reduce({}) { |memo, attr| memo.merge attr => attr }
      end
      return if mutilize_columns_map

      @mutilize_columns_map = mutilize_attrs.reduce({}) do |memo, attr|
        memo.merge attr => (mutilize_kwargs[:map_columns][attr] || attr)
      end
    end
  end

  private

  def mutilitize_around_save
    persisted_and_changed = persisted? && changed?
    yield
    return unless persisted_and_changed && saved_changes?

    mutilitize_create_change_record
  end

  def mutilitize_create_change_record
    change_params = self.class.mutilize_attrs.reduce({}) do |memo, attr|
      memo.merge self.class.mutilize_columns_map[attr] => attribute_before_last_save(attr.to_s)
    end

    change_params[self.class.mutilize_reference_sym] = self

    self.class.mutilize_change_model.create! change_params
  end
end
