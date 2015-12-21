class RecordWindowLayout < MK::WindowLayout
  MAIN_WINDOW_IDENTIFIER = 'RECORD_WINDOW'

  def  initialize(meta, record_data = nil)
    @meta = meta
    @record_data = record_data

    super()
    @used_types = ['Edm.String',
                   'Edm.Boolean',
                   'Edm.Int16',
                   'Edm.Int32',
                   'Edm.Guid',
                   'Edm.DateTime',
                   'Edm.Double']

  end

  def used_types
    @used_types
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
    height 3000 # fix auto size to fit content

    @last_y_pos = 40
    @meta['all_attributes'].each do | attr |


      #      p attr
      #      if @used_types.include? attr['type'] || attr['foreign_end_point']

      #       if (attr['type']=='Edm.Guid' && attr['foreign_end_point']) || attr['type'] != 'Edm.Guid'

      #LABEL
      add NSTextField, "#{attr['name']}_label".to_sym do

      p attr if attr['name']=='ID'

      editable false
      selectable false
      bordered false

      cell do
        alignment NSRightTextAlignment
        scrollable false
        drawsBackground false
      end

      if attr['mandatory']
        mandatory_text = " (mandatory)"
        text_color NSColor.redColor
      else
        mandatory_text = ''
      end
      stringValue attr['name'].underscore.tr("_", " ").capitalize + mandatory_text

      constraints do
        width 200
        top.equals(:superview, :top).plus(@last_y_pos)
        right.equals(:superview, :left).plus(210)
      end
    end
    #        end
    #
    p attr unless attr['type']

    case attr['type']
    when 'Edm.Int16', 'Edm.Int32', 'Edm.Double'
      add NSTextField, attr['name'].to_sym do
        stringValue @record_data[0][ attr['name'].underscore ].to_s
        tool_tip attr['desc']
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
    when 'Edm.Guid'
      if attr['foreign_end_point']
        add NSTextField, attr['name'].to_sym do
          stringValue @record_data[0][ attr['name'].underscore ].to_s
          tool_tip attr['desc']
          constraints do
            width 300
            top.equals(:superview, :top).plus(@last_y_pos)
            right.equals(:superview, :left).plus(530)
          end
        end

        add NSButton, "#{attr['name']}_get_related".to_sym do
          title attr['foreign_end_point']
          constraints do
            width 100
            top.equals(:superview, :top).plus(@last_y_pos)
            right.equals(:superview, :left).plus(640)
            @last_y_pos += 30
          end
        end

      else

        add NSTextField, attr['name'].to_sym do

          editable false
          selectable false
          bordered false

          stringValue @record_data[0][ attr['name'].underscore ].to_s
          tool_tip attr['desc']
          constraints do
            width 300
            top.equals(:superview, :top).plus(@last_y_pos)
            right.equals(:superview, :left).plus(530)
            @last_y_pos += 30
          end
        end

      end
    when 'Edm.DateTime'
      add NSTextField, attr['name'].to_sym do
        stringValue @record_data[0][ attr['name'].underscore ].to_s
        tool_tip attr['desc']
        constraints do
          width 200
          top.equals(:superview, :top).plus(@last_y_pos)
          right.equals(:superview, :left).plus(430)
        end
      end

      add NSButton, "#{attr['name']}_set_date".to_sym do
        title 'date'
        constraints do
          width 70
          top.equals(:superview, :top).plus(@last_y_pos)
          right.equals(:superview, :left).plus(520)
          @last_y_pos += 30
        end
      end

    when 'Edm.String'
      add NSTextField, attr['name'].to_sym do
        stringValue @record_data[0][ attr['name'].underscore ].to_s
        tool_tip attr['desc']
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
        tool_tip attr['desc']
        bezel_style 0

        constraints do
          width 400
          top.equals(:superview, :top).plus(@last_y_pos)
          right.equals(:superview, :left).plus(630)
          @last_y_pos += 30
        end
      end
    else
      #          p "No form handler found for:" + attr['type']
      if attr['foreign_end_point']
        add NSTextField, attr['name'].to_sym do
          stringValue @record_data[0][ attr['name'].underscore ].to_s
          tool_tip attr['desc']
          constraints do
            width 400
            top.equals(:superview, :top).plus(@last_y_pos)
            right.equals(:superview, :left).plus(630)
          end
        end

        add NSButton, "#{attr['name']}_get_related".to_sym do
          title attr['foreign_end_point']
          constraints do
            width 200
            top.equals(:superview, :top).plus(@last_y_pos)
            right.equals(:superview, :left).plus(840)
            @last_y_pos += 30
          end
        end
      else

        p attr

      end

    end



    end

  end

end
