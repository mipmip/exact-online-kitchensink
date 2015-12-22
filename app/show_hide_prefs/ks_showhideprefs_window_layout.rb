class ShowHidePrefsWindowLayout < MK::WindowLayout
  MAIN_WINDOW_IDENTIFIER = 'SHOWHIDE_WINDOW'

  def initialize(meta)
    @meta = meta

    defaults = NSUserDefaults.standardUserDefaults
    @showhide_arr = defaults.objectForKey("showhide_#{@meta['end_point']}")

    super()
  end

  def layout
    frame [[100, 100], [380, 360]], 'ShowHidePrefsLayout'

    add NSView, :title_view
    add NSScrollView, :scroll_view_form do
      document_view add NSView, :container_view
    end
    add NSButton, :save_button
    add NSButton, :cancel_button
  end

  def title_view_style
    constraints do
      top.equals(:superview, :top)
      left.equals(:superview, :left)
      right.equals(:superview, :right)
      height 40
    end

    add NSTextField, :title_text do
      stringValue "Show hide fields in list"

      editable false
      selectable false
      bordered false
      cell do
        alignment NSCenterTextAlignment
        scrollable false
        drawsBackground false
      end
      constraints do
        top.equals(:superview, :top)
        bottom.equals(:superview, :bottom)
        left.equals(:superview, :left)
        right.equals(:superview, :right)
      end
    end

  end

  def scroll_view_form_style
    frame v.superview.bounds
    has_vertical_scroller true

    constraints do
      top.equals(:superview, :top).plus(80)
      left.equals(:superview, :left)
      right.equals(:superview, :right)
      bottom.equals(:superview, :bottom).minus(40)
    end
  end

  def cancel_button_style
    title "Cancel"
    constraints do
      width 100
      height 20
      right.equals(:save_button, :left).minus(10)
      bottom.equals(:superview, :bottom).minus(10)
    end
  end

  def save_button_style
    title "Save"
    constraints do
      width 100
      height 20
      right.equals(:superview, :right).minus(10)
      bottom.equals(:superview, :bottom).minus(10)
    end
  end

  def container_view_style

    frame v.superview.bounds
    height (@meta['all_attributes'].length * 31) + 30

    @last_y_pos = 40
    @meta['all_attributes'].each do | attr |

      add NSButton, attr['name'].to_sym do

        if @showhide_arr && @showhide_arr[attr['name'].underscore]
          state NSOnState
        else
          state NSOffState
        end

        title attr['name'].underscore.tr("_", " ").capitalize

        button_type NSSwitchButton
        tool_tip attr['desc']
        bezel_style 0

        constraints do
          width 400
          top.equals(:superview, :top).plus(@last_y_pos)
          left.equals(:superview, :left).plus(20)
          @last_y_pos += 30
        end
      end

    end

  end

end
