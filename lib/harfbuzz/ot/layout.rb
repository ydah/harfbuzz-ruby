# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Layout table queries (GSUB/GPOS)
    module Layout
      module_function

      # @param face [Face] Font face
      # @return [Boolean] true if the face has GDEF glyph classes
      def has_glyph_classes?(face)
        C.from_hb_bool(C.hb_ot_layout_has_glyph_classes(face.ptr))
      end

      # @param face [Face] Font face
      # @return [Boolean] true if the face has a GSUB table
      def has_substitution?(face)
        C.from_hb_bool(C.hb_ot_layout_has_substitution(face.ptr))
      end

      # @param face [Face] Font face
      # @return [Boolean] true if the face has a GPOS table
      def has_positioning?(face)
        C.from_hb_bool(C.hb_ot_layout_has_positioning(face.ptr))
      end

      # Returns the glyph class from GDEF
      # @param face [Face] Font face
      # @param glyph [Integer] Glyph ID
      # @return [Symbol] Glyph class (:base_glyph, :ligature, :mark, :component)
      def glyph_class(face, glyph)
        C.hb_ot_layout_get_glyph_class(face.ptr, glyph)
      end

      # Returns all glyphs in a given GDEF class
      # @param face [Face] Font face
      # @param klass [Symbol] Glyph class
      # @return [HarfBuzz::Set] Set of glyph IDs
      def glyphs_in_class(face, klass)
        set = HarfBuzz::Set.new
        C.hb_ot_layout_get_glyphs_in_class(face.ptr, klass, set.ptr)
        set
      end

      # Returns the script tags for a table
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB (0x47535542) or GPOS (0x47504F53)
      # @return [Array<Integer>] Script tags
      def script_tags(face, table_tag)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        C.hb_ot_layout_table_get_script_tags(face.ptr, table_tag, 0, count_ptr, nil)
        count = count_ptr.read_uint
        return [] if count.zero?

        tags_ptr = FFI::MemoryPointer.new(:uint32, count)
        count_ptr.write_uint(count)
        C.hb_ot_layout_table_get_script_tags(face.ptr, table_tag, 0, count_ptr, tags_ptr)
        tags_ptr.read_array_of_uint32(count_ptr.read_uint)
      end

      # Returns the feature tags for a table
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @return [Array<Integer>] Feature tags
      def feature_tags(face, table_tag)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        C.hb_ot_layout_table_get_feature_tags(face.ptr, table_tag, 0, count_ptr, nil)
        count = count_ptr.read_uint
        return [] if count.zero?

        tags_ptr = FFI::MemoryPointer.new(:uint32, count)
        count_ptr.write_uint(count)
        C.hb_ot_layout_table_get_feature_tags(face.ptr, table_tag, 0, count_ptr, tags_ptr)
        tags_ptr.read_array_of_uint32(count_ptr.read_uint)
      end

      # Collects all lookups referenced by features
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param scripts [Array<Integer>, nil] Script tags filter (nil = all)
      # @param languages [Array<Integer>, nil] Language tags filter (nil = all)
      # @param features [Array<Integer>, nil] Feature tags filter (nil = all)
      # @return [HarfBuzz::Set] Set of lookup indices
      def collect_lookups(face, table_tag, scripts: nil, languages: nil, features: nil)
        set = HarfBuzz::Set.new
        scripts_ptr  = build_tag_array_ptr(scripts)
        languages_ptr = build_tag_array_ptr(languages)
        features_ptr  = build_tag_array_ptr(features)
        C.hb_ot_layout_collect_lookups(
          face.ptr, table_tag, scripts_ptr, languages_ptr, features_ptr, set.ptr
        )
        set
      end

      # Collects all feature indices
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @return [HarfBuzz::Set] Set of feature indices
      def collect_features(face, table_tag, scripts: nil, languages: nil, features: nil)
        set = HarfBuzz::Set.new
        scripts_ptr   = build_tag_array_ptr(scripts)
        languages_ptr = build_tag_array_ptr(languages)
        features_ptr  = build_tag_array_ptr(features)
        C.hb_ot_layout_collect_features(
          face.ptr, table_tag, scripts_ptr, languages_ptr, features_ptr, set.ptr
        )
        set
      end

      # Converts script+language to OT tags
      # @param script [Integer] Script value
      # @param language [FFI::Pointer] Language pointer
      # @return [Array<Array<Integer>>] [script_tags, language_tags]
      def tags_from_script_and_language(script, language)
        s_count = FFI::MemoryPointer.new(:uint)
        l_count = FFI::MemoryPointer.new(:uint)
        s_count.write_uint(8)
        l_count.write_uint(8)
        s_tags = FFI::MemoryPointer.new(:uint32, 8)
        l_tags = FFI::MemoryPointer.new(:uint32, 8)
        C.hb_ot_tags_from_script_and_language(script, language, s_count, s_tags, l_count, l_tags)
        [
          s_tags.read_array_of_uint32(s_count.read_uint),
          l_tags.read_array_of_uint32(l_count.read_uint)
        ]
      end

      # Converts OT tags to script + language
      # @param script_tag [Integer] OT script tag
      # @param language_tag [Integer] OT language tag
      # @return [Array] [script, language_ptr]
      def tags_to_script_and_language(script_tag, language_tag)
        script_ptr = FFI::MemoryPointer.new(:uint32)
        lang_ptr = FFI::MemoryPointer.new(:pointer)
        C.hb_ot_tags_to_script_and_language(script_tag, language_tag, script_ptr, lang_ptr)
        [script_ptr.read_uint32, lang_ptr.read_pointer]
      end

      # Converts an OT tag to a language pointer
      # @param tag [Integer] Language tag
      # @return [FFI::Pointer] Language pointer
      def tag_to_language(tag)
        C.hb_ot_tag_to_language(tag)
      end

      # Converts an OT tag to a script value
      # @param tag [Integer] Script tag
      # @return [Integer] Script value
      def tag_to_script(tag)
        C.hb_ot_tag_to_script(tag)
      end

      def build_tag_array_ptr(tags)
        return FFI::Pointer::NULL unless tags

        ptr = FFI::MemoryPointer.new(:uint32, tags.size + 1)
        ptr.put_array_of_uint32(0, tags)
        ptr.put_uint32(tags.size * 4, HarfBuzz::C::HB_SET_VALUE_INVALID)
        ptr
      end
      private_class_method :build_tag_array_ptr
    end
  end
end
