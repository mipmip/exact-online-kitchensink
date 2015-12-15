module KitchenSinkExamples
  class KitchenSinkProjectController < KSSuperController

    def initialize

      @title = 'Projects'
      @end_point = 'Projects'
      @layout = layout

      prepare_views

      @meta = NSApplication.sharedApplication.delegate.resource_meta(@end_point)
      @data = []

      sync_exact_data

      @table_view = @layout.get(:table_view)
      @table_view.delegate = self
      @table_view.dataSource = self
    end

    def layout
      @layout ||= KitchenSinkProjectLayout.new
    end

    def numberOfRowsInTableView(table_view)
      @data.length
    end

    def prepare_views
      @sync_button = @layout.get(:sync_button)
      @sync_button.target = self
      @sync_button.action = 'sync_exact_data'

      @add_button = @layout.get(:add_button)
      @add_button.target = self
      @add_button.action = 'add_record_window'

      @edit_button = @layout.get(:edit_button)
      @edit_button.target = self
      @edit_button.action = 'edit_record_window'
    end

    def record_window(record_data=nil)
      #p record_data
      @record_window_controller ||= RecordWindowController.alloc.init_with_meta(@meta, record_data)
    end

    def add_record_window
      record_window
      @record_window_controller.showWindow(self)
      @record_window_controller.window.orderFrontRegardless
    end

    def edit_record_window
      record_id = @data[@table_view.selectedRow]['id']
      get_record_data(record_id)
    end

    def sync_exact_data
      @task_data = NSTask.alloc.init

      @task_data.setLaunchPath "/Users/pim/RnD/exact-online-kitchensink/bin/eo"
      @task_data.setCurrentDirectoryPath "/Users/pim/RnD/exact-online-kitchensink"
      @task_data.setArguments(['projects', 'jsonlist'])

      @outputPipe = NSPipe.pipe
      @task_data.setStandardOutput @outputPipe

      @notification_center = NSNotificationCenter.defaultCenter
      @notification_center.addObserver(self, selector:'readCompletedData:', name:NSFileHandleReadToEndOfFileCompletionNotification, object:@outputPipe.fileHandleForReading)

      @outputPipe.fileHandleForReading.readToEndOfFileInBackgroundAndNotify
      @task_data.launch
    end

    def readCompletedData(notification)
      result = notification.userInfo.objectForKey(NSFileHandleNotificationDataItem)
      @data = BW::JSON.parse result

      @table_view.reloadData
      NSNotificationCenter.defaultCenter.removeObserver(self, name: NSFileHandleReadToEndOfFileCompletionNotification, object: notification.object)
    end

    def get_record_data(record_id)
      @task_data2 = NSTask.alloc.init
      @task_data2.setLaunchPath "/Users/pim/RnD/exact-online-kitchensink/bin/eo"
      @task_data2.setCurrentDirectoryPath "/Users/pim/RnD/exact-online-kitchensink"
      @task_data2.setArguments(['projects', 'jsonlist', '-f', "id=#{record_id}", '-C'])
      #@task_data2.setArguments(['projects', 'jsonlist'])

      print "\n/Users/pim/RnD/exact-online-kitchensink/bin/eo " + ['projects', 'jsonlist', '-f', "id=#{record_id}", '-C'].join(' ')
      @outputPipe2 = NSPipe.pipe
      @task_data2.setStandardOutput @outputPipe2

      @notification_center2 = NSNotificationCenter.defaultCenter
      @notification_center2.addObserver(self,
                                       selector:'readCompletedDataGetRecord:',
                                       name:NSFileHandleReadToEndOfFileCompletionNotification,
                                       object:@outputPipe2.fileHandleForReading)

      @outputPipe2.fileHandleForReading.readToEndOfFileInBackgroundAndNotify
      @task_data2.launch
    end

    def readCompletedDataGetRecord(notification)
      result = notification.userInfo.objectForKey(NSFileHandleNotificationDataItem)

      @notification_center2.removeObserver(self, name: NSFileHandleReadToEndOfFileCompletionNotification, object: notification.object)

      record_window BW::JSON.parse(result)

      @record_window_controller.showWindow(self)
      @record_window_controller.window.orderFrontRegardless
    end


    def tableView(table_view, viewForTableColumn: column, row: row)
      text_field = table_view.makeViewWithIdentifier(column.identifier, owner: self)

      unless text_field
        text_field = NSTextField.alloc.initWithFrame([[0, 0], [column.width, 0]])
        text_field.identifier = column.identifier
        text_field.editable = false
        text_field.drawsBackground = false
        text_field.bezeled = false
      end

      row = @data[row]

      case column.identifier
      when 'code'
        text_field.stringValue = row[:code]
      when 'description'
        text_field.stringValue = row[:description]
      end

      return text_field
    end

    def tableViewColumnDidResize(notification)
    end
  end
end
