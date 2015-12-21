class KitchenSinkProjectLayout < MK::Layout
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
        title "Add"
        constraints do
          width 100
          top.equals(:scroll_view, :bottom).plus(10)
          left.equals(:superview, :left).plus(10)
        end
      end

      add NSButton, :delete_button do
        title "Delete"
        constraints do
          width 100
          top.equals(:scroll_view, :bottom).plus(10)
          left.equals(:add_button, :right).plus(10)
        end
      end

      add NSButton, :edit_button do
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
          right.equals(:superview, :right).minus(10)
        end
      end

    end
  end

  def scroll_view_style
        frame v.superview.bounds

        constraints do
          top.equals(:superview, :top).plus(50)
          right.equals(:superview, :right).minus(0)
          left.equals(:superview, :left).plus(0)
          bottom.equals(:superview, :bottom).minus(50)
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

    add_column('id') do
      title 'ID'
      min_width 102
      width 270
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('code') do
      title 'Code'
      min_width 102
      width 170
      resizing_mask NSTableColumnUserResizingMask
    end

    add_column('description') do
      title 'Description'
      min_width 102
      width parent_bounds.size.width - 170
      resizingMask NSTableColumnAutoresizingMask
    end
  end
end
