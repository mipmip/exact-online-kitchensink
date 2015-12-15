class RecordWindowLayout < MK::WindowLayout
  MAIN_WINDOW_IDENTIFIER = 'RECORD_WINDOW'

  def  initialize(meta, record_data = nil)
    @meta = meta
    @record_data = record_data

    @used_types = ['Edm.String',
                   'Edm.Boolean',
                   'Edm.Int16',
                   'Edm.Int32',
                   'Edm.Double']
    super()

  end

  def layout
    frame [[100, 100], [480, 560]], 'RecordLayout'

    add NSView, :title_view
    add NSScrollView, :scroll_view_form do
      document_view add NSView, :container_view
    end
    add NSButton, :save_button
  end

  def title_view_style
    constraints do
      top.equals(:superview, :top)
      left.equals(:superview, :left)
      right.equals(:superview, :right)
      height 80
    end

    add NSTextField, :title_text do
      stringValue "Edit Project: CODE"

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

    @last_y_pos = 40
    @meta['all_attributes'].each do | attr |

      if @used_types.include? attr['type']

        #LABEL
        add NSTextField, attr['name'].to_sym do

          editable false
          selectable false
          bordered false

          cell do
            alignment NSRightTextAlignment
            scrollable false
            drawsBackground false
          end

          stringValue attr['name'].underscore.tr("_", " ").capitalize

          constraints do
            width 200
            top.equals(:superview, :top).plus(@last_y_pos)
            right.equals(:superview, :left).plus(210)
          end
        end

        case attr['type']
        when 'Edm.Int16', 'Edm.Int32', 'Edm.Double'
          add NSTextField, attr['name'].to_sym do
            stringValue @record_data[0][ attr['name'].underscore ].to_s
            tool_tip  attr['desc']
            cell do
              alignment NSRightTextAlignment
            end
            constraints do
              width 100
              top.equals(:superview, :top).plus(@last_y_pos)
              right.equals(:superview, :left).plus(330)
              @last_y_pos += 30
            end
          end
        when 'Edm.String'
          add NSTextField, attr['name'].to_sym do
            stringValue @record_data[0][ attr['name'].underscore ].to_s
            tool_tip  attr['desc']
            constraints do
              width 400
              top.equals(:superview, :top).plus(@last_y_pos)
              right.equals(:superview, :left).plus(630)
              @last_y_pos += 30
            end
          end
        when 'Edm.Boolean'
          add NSButton, attr['name'].to_sym do
            title @record_data[0][ attr['name'].underscore ].to_s
            button_type NSSwitchButton
            tool_tip  attr['desc']
            bezel_style 0

            constraints do
              width 400
              top.equals(:superview, :top).plus(@last_y_pos)
              right.equals(:superview, :left).plus(630)
              @last_y_pos += 30
            end
          end
        else
          p "No form handler found for:" + attr['type']
        end

      else
        p "#{attr['name']}:#{attr['type']}"
        p attr
      end


    end

  end

end
