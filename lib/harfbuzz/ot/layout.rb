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

      # Returns attachment point list for a glyph
      # @param face [Face] Font face
      # @param glyph [Integer] Glyph ID
      # @return [Array<Integer>] Attachment point indices
      def attach_points(face, glyph)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        total = C.hb_ot_layout_get_attach_points(face.ptr, glyph, 0, count_ptr, nil)
        return [] if total.zero?

        points_ptr = FFI::MemoryPointer.new(:uint, total)
        count_ptr.write_uint(total)
        C.hb_ot_layout_get_attach_points(face.ptr, glyph, 0, count_ptr, points_ptr)
        points_ptr.read_array_of_uint(count_ptr.read_uint)
      end

      # Returns ligature caret positions for a glyph
      # @param font [Font] Font
      # @param dir [Symbol] Direction (:ltr, :rtl)
      # @param glyph [Integer] Glyph ID
      # @return [Array<Integer>] Caret positions
      def ligature_carets(font, dir, glyph)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        total = C.hb_ot_layout_get_ligature_carets(font.ptr, dir, glyph, 0, count_ptr, nil)
        return [] if total.zero?

        carets_ptr = FFI::MemoryPointer.new(:int32, total)
        count_ptr.write_uint(total)
        C.hb_ot_layout_get_ligature_carets(font.ptr, dir, glyph, 0, count_ptr, carets_ptr)
        carets_ptr.read_array_of_int32(count_ptr.read_uint)
      end

      # Finds a script in the table, returns [found, index]
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_tag [Integer] Script tag to find
      # @return [Array] [Boolean, Integer] found and script index
      def find_script(face, table_tag, script_tag)
        idx_ptr = FFI::MemoryPointer.new(:uint)
        found = C.from_hb_bool(
          C.hb_ot_layout_table_find_script(face.ptr, table_tag, script_tag, idx_ptr)
        )
        [found, idx_ptr.read_uint]
      end

      # Selects the best matching script from a list
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_tags [Array<Integer>] Candidate script tags (in preference order)
      # @return [Array] [Boolean, Integer, Integer] exact_match, script_index, chosen_script_tag
      def select_script(face, table_tag, script_tags)
        tags_ptr = FFI::MemoryPointer.new(:uint32, script_tags.size)
        tags_ptr.put_array_of_uint32(0, script_tags)
        idx_ptr = FFI::MemoryPointer.new(:uint)
        chosen_tag_ptr = FFI::MemoryPointer.new(:uint32)
        exact = C.from_hb_bool(
          C.hb_ot_layout_table_select_script(
            face.ptr, table_tag, script_tags.size, tags_ptr, idx_ptr, chosen_tag_ptr
          )
        )
        [exact, idx_ptr.read_uint, chosen_tag_ptr.read_uint32]
      end

      # Returns language tags for a script
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_index [Integer] Script index
      # @return [Array<Integer>] Language tags
      def language_tags(face, table_tag, script_index)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        total = C.hb_ot_layout_script_get_language_tags(
          face.ptr, table_tag, script_index, 0, count_ptr, nil
        )
        return [] if total.zero?

        tags_ptr = FFI::MemoryPointer.new(:uint32, total)
        count_ptr.write_uint(total)
        C.hb_ot_layout_script_get_language_tags(
          face.ptr, table_tag, script_index, 0, count_ptr, tags_ptr
        )
        tags_ptr.read_array_of_uint32(count_ptr.read_uint)
      end

      # Selects the best matching language, returns [found, language_index]
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_index [Integer] Script index
      # @param language_tags [Array<Integer>] Candidate language tags
      # @return [Array] [Boolean, Integer] found and language index
      def select_language(face, table_tag, script_index, language_tags)
        tags_ptr = FFI::MemoryPointer.new(:uint32, language_tags.size)
        tags_ptr.put_array_of_uint32(0, language_tags)
        lang_idx_ptr = FFI::MemoryPointer.new(:uint)
        found = C.from_hb_bool(
          C.hb_ot_layout_script_select_language(
            face.ptr, table_tag, script_index,
            language_tags.size, tags_ptr, lang_idx_ptr
          )
        )
        [found, lang_idx_ptr.read_uint]
      end

      # Returns the required feature index for a language, or nil if none
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_index [Integer] Script index
      # @param language_index [Integer] Language index
      # @return [Integer, nil] Feature index or nil
      def required_feature_index(face, table_tag, script_index, language_index)
        idx_ptr = FFI::MemoryPointer.new(:uint)
        found = C.from_hb_bool(
          C.hb_ot_layout_language_get_required_feature_index(
            face.ptr, table_tag, script_index, language_index, idx_ptr
          )
        )
        found ? idx_ptr.read_uint : nil
      end

      # Returns [feature_index, feature_tag] for the required feature, or nil
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_index [Integer] Script index
      # @param language_index [Integer] Language index
      # @return [Array, nil] [feature_index, feature_tag] or nil
      def required_feature(face, table_tag, script_index, language_index)
        idx_ptr = FFI::MemoryPointer.new(:uint)
        tag_ptr = FFI::MemoryPointer.new(:uint32)
        found = C.from_hb_bool(
          C.hb_ot_layout_language_get_required_feature(
            face.ptr, table_tag, script_index, language_index, idx_ptr, tag_ptr
          )
        )
        found ? [idx_ptr.read_uint, tag_ptr.read_uint32] : nil
      end

      # Returns feature indices for a language
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_index [Integer] Script index
      # @param language_index [Integer] Language index
      # @return [Array<Integer>] Feature indices
      def feature_indexes(face, table_tag, script_index, language_index)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        total = C.hb_ot_layout_language_get_feature_indexes(
          face.ptr, table_tag, script_index, language_index, 0, count_ptr, nil
        )
        return [] if total.zero?

        idx_ptr = FFI::MemoryPointer.new(:uint, total)
        count_ptr.write_uint(total)
        C.hb_ot_layout_language_get_feature_indexes(
          face.ptr, table_tag, script_index, language_index, 0, count_ptr, idx_ptr
        )
        idx_ptr.read_array_of_uint(count_ptr.read_uint)
      end

      # Returns feature tags for a language
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_index [Integer] Script index
      # @param language_index [Integer] Language index
      # @return [Array<Integer>] Feature tags
      def feature_tags_for_lang(face, table_tag, script_index, language_index)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        total = C.hb_ot_layout_language_get_feature_tags(
          face.ptr, table_tag, script_index, language_index, 0, count_ptr, nil
        )
        return [] if total.zero?

        tags_ptr = FFI::MemoryPointer.new(:uint32, total)
        count_ptr.write_uint(total)
        C.hb_ot_layout_language_get_feature_tags(
          face.ptr, table_tag, script_index, language_index, 0, count_ptr, tags_ptr
        )
        tags_ptr.read_array_of_uint32(count_ptr.read_uint)
      end

      # Finds a specific feature in a language, returns [found, feature_index]
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param script_index [Integer] Script index
      # @param language_index [Integer] Language index
      # @param feature_tag [Integer] Feature tag to find
      # @return [Array] [Boolean, Integer] found and feature index
      def find_feature(face, table_tag, script_index, language_index, feature_tag)
        idx_ptr = FFI::MemoryPointer.new(:uint)
        found = C.from_hb_bool(
          C.hb_ot_layout_language_find_feature(
            face.ptr, table_tag, script_index, language_index, feature_tag, idx_ptr
          )
        )
        [found, idx_ptr.read_uint]
      end

      # Returns lookup indices for a feature
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param feature_index [Integer] Feature index
      # @return [Array<Integer>] Lookup indices
      def feature_lookups(face, table_tag, feature_index)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        total = C.hb_ot_layout_feature_get_lookups(
          face.ptr, table_tag, feature_index, 0, count_ptr, nil
        )
        return [] if total.zero?

        idx_ptr = FFI::MemoryPointer.new(:uint, total)
        count_ptr.write_uint(total)
        C.hb_ot_layout_feature_get_lookups(
          face.ptr, table_tag, feature_index, 0, count_ptr, idx_ptr
        )
        idx_ptr.read_array_of_uint(count_ptr.read_uint)
      end

      # Returns size design parameters for the face
      # @param face [Face] Font face
      # @return [Hash, nil] Size params hash or nil if not available
      def size_params(face)
        design_size_ptr    = FFI::MemoryPointer.new(:uint)
        subfamily_id_ptr   = FFI::MemoryPointer.new(:uint)
        name_id_ptr        = FFI::MemoryPointer.new(:uint)
        range_start_ptr    = FFI::MemoryPointer.new(:uint)
        range_end_ptr      = FFI::MemoryPointer.new(:uint)
        found = C.from_hb_bool(
          C.hb_ot_layout_get_size_params(
            face.ptr,
            design_size_ptr, subfamily_id_ptr, name_id_ptr,
            range_start_ptr, range_end_ptr
          )
        )
        return nil unless found

        {
          design_size: design_size_ptr.read_uint,
          subfamily_id: subfamily_id_ptr.read_uint,
          subfamily_name_id: name_id_ptr.read_uint,
          range_start: range_start_ptr.read_uint,
          range_end: range_end_ptr.read_uint
        }
      end

      # Returns OpenType feature UI name IDs
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param feature_index [Integer] Feature index
      # @return [Hash, nil] Name ID hash or nil
      def feature_name_ids(face, table_tag, feature_index)
        label_id_ptr       = FFI::MemoryPointer.new(:uint)
        tooltip_id_ptr     = FFI::MemoryPointer.new(:uint)
        sample_id_ptr      = FFI::MemoryPointer.new(:uint)
        num_params_ptr     = FFI::MemoryPointer.new(:uint)
        found = C.from_hb_bool(
          C.hb_ot_layout_feature_get_name_ids(
            face.ptr, table_tag, feature_index,
            label_id_ptr, tooltip_id_ptr, sample_id_ptr, num_params_ptr
          )
        )
        return nil unless found

        {
          label_id: label_id_ptr.read_uint,
          tooltip_id: tooltip_id_ptr.read_uint,
          sample_id: sample_id_ptr.read_uint,
          num_named_parameters: num_params_ptr.read_uint
        }
      end

      # Returns codepoints for a named feature's characters
      # @param face [Face] Font face
      # @param table_tag [Integer] GSUB or GPOS tag
      # @param feature_index [Integer] Feature index
      # @return [Array<Integer>] Codepoints
      def feature_characters(face, table_tag, feature_index)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        total = C.hb_ot_layout_feature_get_characters(
          face.ptr, table_tag, feature_index, 0, count_ptr, nil
        )
        return [] if total.zero?

        cps_ptr = FFI::MemoryPointer.new(:uint32, total)
        count_ptr.write_uint(total)
        C.hb_ot_layout_feature_get_characters(
          face.ptr, table_tag, feature_index, 0, count_ptr, cps_ptr
        )
        cps_ptr.read_array_of_uint32(count_ptr.read_uint)
      end

      # Returns a baseline coordinate value
      # @param font [Font] Font
      # @param baseline_tag [Integer] Baseline tag (HB_OT_LAYOUT_BASELINE_TAG_*)
      # @param dir [Symbol] Direction (:ltr, :rtl, :ttb, :btt)
      # @param script_tag [Integer] Script tag
      # @param language [FFI::Pointer, nil] Language pointer (nil = default)
      # @return [Integer, nil] Baseline coordinate or nil if not available
      def baseline(font, baseline_tag, dir, script_tag, language = nil)
        lang_ptr = language || FFI::Pointer::NULL
        coord_ptr = FFI::MemoryPointer.new(:int32)
        found = C.from_hb_bool(
          C.hb_ot_layout_get_baseline(
            font.ptr, baseline_tag, dir, script_tag, lang_ptr, coord_ptr
          )
        )
        found ? coord_ptr.read_int32 : nil
      end

      # Returns a baseline coordinate with fallback
      # @param font [Font] Font
      # @param baseline_tag [Integer] Baseline tag
      # @param dir [Symbol] Direction
      # @param script_tag [Integer] Script tag
      # @param language [FFI::Pointer, nil] Language pointer
      # @return [Integer] Baseline coordinate (with fallback)
      def baseline_with_fallback(font, baseline_tag, dir, script_tag, language = nil)
        lang_ptr = language || FFI::Pointer::NULL
        coord_ptr = FFI::MemoryPointer.new(:int32)
        C.hb_ot_layout_get_baseline_with_fallback(
          font.ptr, baseline_tag, dir, script_tag, lang_ptr, coord_ptr
        )
        coord_ptr.read_int32
      end

      # Returns font extents from OT tables
      # @param font [Font] Font
      # @param dir [Symbol] Direction
      # @param script_tag [Integer] Script tag
      # @param language [FFI::Pointer, nil] Language pointer
      # @return [Hash, nil] Font extents hash or nil
      def font_extents(font, dir, script_tag, language = nil)
        lang_ptr = language || FFI::Pointer::NULL
        extents = C::HbFontExtentsT.new
        found = C.from_hb_bool(
          C.hb_ot_layout_get_font_extents(
            font.ptr, dir, script_tag, lang_ptr, extents.to_ptr
          )
        )
        return nil unless found

        {
          ascender: extents[:ascender],
          descender: extents[:descender],
          line_gap: extents[:line_gap]
        }
      end

      # Returns the horizontal baseline tag for a script
      # @param script [Integer] Script value
      # @return [Integer] Baseline tag
      def horizontal_baseline_tag_for_script(script)
        C.hb_ot_layout_get_horizontal_baseline_tag_for_script(script)
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
