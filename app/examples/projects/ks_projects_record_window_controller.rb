class RecordWindowController  < NSWindowController
  def layout
    @layout ||= RecordWindowLayout.new
  end

  def init
    super.tap do
      self.window = layout.window
    end

  end


end

