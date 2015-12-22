class ListViewLayout < MK::Layout
  def initialize(meta)
    @meta = meta

    load_prefs
    super()
  end

  def load_prefs
    defaults = NSUserDefaults.standardUserDefaults
    @showhide_arr = defaults.objectForKey("showhide_#{@meta['end_point']}")
  end

  def layout
    root(NSView, :outer_view) do
      frame [[0, 0], [480, 360]]

      autoresizing_mask NSViewWidthSizable | NSViewHeightSizable

      add NSButton, :filter_button do
        title "Filter"
        constraints do
          width 100
          top.equals(:superview, :top).plus(10)
          right.equals(:superview, :right).minus(10)
        end
      end

      add NSTextField, :filter_text_field do
        constraints do
          top.equals(:superview, :top).plus(10)
          left.equals(:superview, :left).plus(10)
          right.equals(:filter_button, :left).minus(10)
        end
      end

      add NSScrollView, :scroll_view

      add NSButton, :add_button do
        unless @meta['supported_methods'].include? 'POST'
          enabled false
        end

        title "Add"
        constraints do
          width 100
          top.equals(:scroll_view, :bottom).plus(10)
          left.equals(:superview, :left).plus(10)
        end
      end

      add NSButton, :delete_button do
        unless @meta['supported_methods'].include? 'DELETE'
          enabled false
        end
        title "Delete"
        constraints do
          width 100
          top.equals(:scroll_view, :bottom).plus(10)
          left.equals(:add_button, :right).plus(10)
        end
      end

      add NSButton, :edit_button do
        unless @meta['supported_methods'].include? 'POST'
          enabled false
        end
        title "Edit"
        constraints do
          width 100
          top.equals(:scroll_view, :bottom).plus(10)
          left.equals(:delete_button, :right).plus(10)
        end
      end

      add NSButton, :sync_button do
        title "Sync"
        constraints do
          width 100
          top.equals(:scroll_view, :bottom).plus(10)
          left.equals(:edit_button, :right).plus(10)
        end
      end

      add NSButton, :showhide_button do
        title "Show/hide fields"
        constraints do
          width 100
          top.equals(:scroll_view, :bottom).plus(10)
          right.equals(:superview, :right).minus(10)
        end
      end

    end
  end

  def scroll_view_style
        frame v.superview.bounds

        constraints do
          top.equals(:superview, :top).plus(40)
          right.equals(:superview, :right).minus(0)
          left.equals(:superview, :left).plus(0)
          bottom.equals(:superview, :bottom).minus(40)
        end

        autoresizing_mask NSViewWidthSizable | NSViewHeightSizable
        has_vertical_scroller true
        set_autoresizes_subviews true

        document_view add NSTableView, :table_view
  end


  def table_view_style

    uses_alternating_row_background_colors true
    row_height 24
    parent_bounds = v.superview.bounds
    frame parent_bounds

    autoresizing_mask NSViewWidthSizable | NSViewHeightSizable

    unless @showhide_arr
      @showhide_arr = {}
      @showhide_arr['id'] = true
    end

    @showhide_arr.each do |k, v|
      add_column(k) do
        hidden true unless v
        title k.tr("_", " ").capitalize
        min_width 100
        width 300
        resizing_mask NSTableColumnUserResizingMask

      end
    end

  end
end
