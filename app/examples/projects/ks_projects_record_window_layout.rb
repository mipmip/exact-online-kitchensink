class RecordWindowLayout < MK::WindowLayout
  MAIN_WINDOW_IDENTIFIER = 'RECORD_WINDOW'

  def  initialize(meta, record_data = nil)
    @meta = meta
    @record_data = record_data

    super()
  end

  def layout
    frame [[100, 100], [480, 560]], 'RecordLayout'

    #@scroll_view =  NSView.new

    add NSView, :scroll_view_form do

      #has_vertical_scroller true
      frame v.superview.bounds
      translatesAutoresizingMaskIntoConstraints
      @last_y_pos = 40
      @meta['all_attributes'].each do | attr |


        used_types = ['Edm.String',
                      'Edm.Boolean',
                      'Edm.Int16',
                      'Edm.Int32',
                      'Edm.Double']

        if used_types.include? attr['type']

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

      #document_view add NSOutlineView, :outline_view
    end

  end

end

