class RecordWindowController  < NSWindowController
  def layout
    @layout ||= RecordWindowLayout.new @meta
  end

  def init_with_meta(meta)
    @meta = meta
    init
  end

  def init
    super.tap do
      self.window = layout.window
    end
  end

end

