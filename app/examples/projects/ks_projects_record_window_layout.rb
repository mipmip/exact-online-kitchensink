class RecordWindowLayout < MK::WindowLayout
  MAIN_WINDOW_IDENTIFIER = 'RECORD_WINDOW'

  def layout
    frame [[100, 100], [480, 360]], 'RecordLayout'

    add NSButton, :hallo_button do
      title "Hallo"
      constraints do
        width 100
        top.equals(:superview, :top).plus(10)
        right.equals(:superview, :right).minus(10)
      end
    end

  end

end

