module KitchenSinkExamples
  class KitchenSinkProjectController < KSSuperController

    def initialize

      @title = 'Projects'
      @layout = layout

      prepare_views

      @data = [
        { code: 'Jamon', description: 'Owner' },
        { code: 'Colin', description: 'Owner' },
      ]

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
    end


    def sync_exact_data
      @task = NSTask.alloc.init

      @task.setLaunchPath "/Users/pim/RnD/exact-online-kitchensink/bin/eo"
      @task.setCurrentDirectoryPath "/Users/pim/RnD/exact-online-kitchensink"
      @task.setArguments(['projects', 'jsonlist'])

      @outputPipe = NSPipe.pipe
      @task.setStandardOutput @outputPipe

      @notification_center = NSNotificationCenter.defaultCenter
      @notification_center.addObserver(self, selector:'readCompleted:', name:NSFileHandleReadToEndOfFileCompletionNotification, object:@outputPipe.fileHandleForReading)

      @outputPipe.fileHandleForReading.readToEndOfFileInBackgroundAndNotify
      @task.launch
    end

    def readCompleted(notification)
      result = notification.userInfo.objectForKey(NSFileHandleNotificationDataItem)

      @data = BW::JSON.parse result
      @data.each do |item|
        p item
      end

      @table_view.reloadData

      # Stop spinner
      # reload table

      NSNotificationCenter.defaultCenter.removeObserver(self, name: NSFileHandleReadToEndOfFileCompletionNotification, object: notification.object)
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
