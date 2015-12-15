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
      prepare_views
    end
  end

  def save_some_record
    p "oh yeaue"
    @field_outlets.each do |k,f|
      p k + "="
      if f.instance_of? NSTextField
        p f.stringValue
      elsif f.instance_of? NSButton
        p f.state
      end
    end
  end

  def prepare_views

#    pointToScrollTo = NSMakePoint(0, 0)
#    @scroll_view = @layout.get(:scroll_view_form)
#    @scroll_view.contentView.scrollToPoint( pointToScrollTo)
#    @scroll_view.reflectScrolledClipView(@scroll_view.contentView)

    @save_button = @layout.get(:save_button)
    @save_button.target = self
    @save_button.action = 'save_some_record'
    @field_outlets = {}

    @meta['all_attributes'].each do | attr |

      if @layout.used_types.include? attr['type']
        @field_outlets[attr['name']] = @layout.get(attr['name'].to_sym)
      end
    end

  end
end
