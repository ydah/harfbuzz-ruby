# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Shape query API
    module Shape
      module_function

      # Returns the set of glyphs that could be produced by the given buffer
      # @param font [Font] Sized font
      # @param buffer [Buffer] Text buffer
      # @param features [Array<Feature>] Features to apply
      # @return [HarfBuzz::Set] Set of glyph IDs
      def glyphs_closure(font, buffer, features = [])
        set = HarfBuzz::Set.new
        features_ptr = HarfBuzz.send(:build_features_ptr, features)
        C.hb_ot_shape_glyphs_closure(
          font.ptr, buffer.ptr, features_ptr, features.size, set.ptr
        )
        set
      end

      # Returns the lookup indices used by a shape plan for a given table
      # @param plan [ShapePlan] Shape plan
      # @param table_tag [Integer] GSUB or GPOS tag
      # @return [HarfBuzz::Set] Set of lookup indices
      def plan_collect_lookups(plan, table_tag)
        set = HarfBuzz::Set.new
        C.hb_ot_shape_plan_collect_lookups(plan.ptr, table_tag, set.ptr)
        set
      end
    end
  end
end
