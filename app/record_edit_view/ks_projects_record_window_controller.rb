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
    #    p @meta
    meta_assoc = {}
    @meta['all_attributes'].each do | attr |
      meta_assoc[attr['name']] = attr
    end

    data_to_save= {}
    @field_outlets.each do |k,f|

      case meta_assoc[k]['type']
      when 'Edm.Int16', 'Edm.Int32'
        data_to_save[k.underscore] = f.intValue unless f.stringValue == ''
      when 'Edm.Double'
        data_to_save[k.underscore] = f.floatValue unless f.stringValue == ''
      when 'Edm.Guid'
        if meta_assoc[k]['foreign_end_point']
          data_to_save[k.underscore] = f.stringValue unless f.stringValue == ''
        else
          #id enzo
          #ignore for now
        end
      when 'Edm.DateTime'
        #ignore for now
        #data_to_save[k.underscore] = f.stringValue unless f.stringValue == ''
      when 'Edm.String'
        data_to_save[k.underscore] = f.stringValue unless f.stringValue == ''
      when 'Edm.Boolean'

        if f.state.zero?
          data_to_save[k.underscore] = false
        else
          data_to_save[k.underscore] = true
        end

      else
        if meta_assoc[k]['foreign_end_point']
          #ignore for now
        else
          #ignore for now
        end
      end

    end

    save_exact_data(@record_data[0]['id'], data_to_save)

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
      @field_outlets[attr['name']] = @layout.get(attr['name'].to_sym)
    end

  end

  def save_exact_data(id,data)
    @task_data = NSTask.alloc.init

    @task_data.setLaunchPath "/Users/pim/RnD/exact-online-kitchensink/bin/eo"
    @task_data.setCurrentDirectoryPath "/Users/pim/RnD/exact-online-kitchensink"
    args = ['projects', 'edit_with_json', id, BW::JSON.generate(data)]
    print args.join(' ')
    @task_data.setArguments(args)

    @outputPipe = NSPipe.pipe
    @task_data.setStandardOutput @outputPipe

    @notification_center = NSNotificationCenter.defaultCenter
    @notification_center.addObserver(self, selector:'readCompletedDataSaveAction:', name:NSFileHandleReadToEndOfFileCompletionNotification, object:@outputPipe.fileHandleForReading)

    @outputPipe.fileHandleForReading.readToEndOfFileInBackgroundAndNotify
    @task_data.launch
  end

  def readCompletedDataSaveAction(notification)
    result = notification.userInfo.objectForKey(NSFileHandleNotificationDataItem)
    p result
    NSNotificationCenter.defaultCenter.removeObserver(self, name: NSFileHandleReadToEndOfFileCompletionNotification, object: notification.object)
  end
end
