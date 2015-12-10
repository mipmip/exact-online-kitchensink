class RecordWindowLayout < MK::WindowLayout
  MAIN_WINDOW_IDENTIFIER = 'RECORD_WINDOW'

  def  initialize meta
    @meta = meta

    super
  end

  def layout
    frame [[100, 100], [480, 360]], 'RecordLayout'

      @scroll_view =  NSView.new

      add @scroll_view, :scroll_view_form do

        #has_vertical_scroller true
        frame v.superview.bounds
        translatesAutoresizingMaskIntoConstraints
        @last_y_pos = 40
        @meta['all_attributes'].each do | attr |
          add NSButton, attr['name'].to_sym do
            title attr['name']
            constraints do
              width 100

              top.equals(:superview, :top).plus(@last_y_pos)
              right.equals(:superview, :left).plus(110)
              @last_y_pos += 100
            end
          end


        end

        #document_view add NSOutlineView, :outline_view
      end

  end

end

