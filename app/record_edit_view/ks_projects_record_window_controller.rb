class RecordWindowController  < NSWindowController
  def layout
    @layout ||= RecordWindowLayout.new(@meta, @record_data)
  end

  def init_with_meta(meta, record_data=nil)
    @meta = meta
    @record_data = record_data
    init
  end

  def init
    super.tap do
      self.window = layout.window
    end
  end

end

