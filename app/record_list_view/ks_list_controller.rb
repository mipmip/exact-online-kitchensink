class ListViewController

  def initialize(end_point)
    @end_point = end_point
    @meta = NSApplication.sharedApplication.delegate.resource_meta(@end_point)

    @layout = layout
    prepare_views

    @data_org = []
    @data = []

    @sync_done = false

#    sync_exact_data

    @table_view = @layout.get(:table_view)
    @table_view.delegate = self
    @table_view.dataSource = self
    @table_view.setTarget(self)
    @table_view.setDoubleAction('edit_record_window') # double click record to edit
  end

  def init_sync
    unless @sync_done
      sync_exact_data
    end
  end

  def object_entry
    @subview = @layout.get :outer_view
    {"Title" => @end_point, "subview"=> @subview, 'EndPoint' => @end_point}
  end

  def layout
    @layout ||= ListViewLayout.new(@meta)
  end

  def numberOfRowsInTableView(table_view)
    @data.length
  end

  def prepare_views

    @outer_view = @layout.get(:outer_view)

    @sync_button = @layout.get(:sync_button)
    @sync_button.target = self
    @sync_button.action = 'sync_exact_data'

    @add_button = @layout.get(:add_button)
    @add_button.target = self
    @add_button.action = 'add_record_window'

    @showhide_button = @layout.get(:showhide_button)
    @showhide_button.target = self
    @showhide_button.action = 'showhide_window'

    @delete_button = @layout.get(:delete_button)
    @delete_button.target = self
    @delete_button.action = 'delete_record'

    @edit_button = @layout.get(:edit_button)
    @edit_button.target = self
    @edit_button.action = 'edit_record_window'

    @filter_button = @layout.get(:filter_button)
    @filter_button.target = self
    @filter_button.action = 'filter'

    @filter_text_field = @layout.get(:filter_text_field)
  end

  # search through all text fields and recreate filter
  def filter

    if @filter_text_field.stringValue == ''
      @data = @data_org
    else

      searchlist = []
      @meta['all_attributes'].each do | attr |
        if attr['type'] == 'Edm.String'
          searchlist << attr['name']
        end
      end

      data_tmp = []
      searchlist.each do |s|
        tmp = @data_org.select {|record| record[s.underscore] && record[s.underscore].include?(@filter_text_field.stringValue) }
        if tmp.length > 0
          data_tmp = data_tmp + tmp
        end
      end

      data_tmp.uniq! {|e| e['id'] }

      @data = data_tmp

    end

    @table_view.reloadData
  end

  def outer_view
    @outer_view
  end

  def delete_record

    DJProgressHUD.showStatus("talking to Exact", FromView:@outer_view)

    record_id = @data[@table_view.selectedRow]['id']
    @task_data3 = NSTask.alloc.init
    @task_data3.setLaunchPath "/Users/pim/RnD/exact-online-kitchensink/bin/eo"
    @task_data3.setCurrentDirectoryPath "/Users/pim/RnD/exact-online-kitchensink"
    @task_data3.setArguments([@end_point.underscore, 'delete', "#{record_id}"])

    @outputPipe3 = NSPipe.pipe
    @task_data3.setStandardOutput @outputPipe3

    @notification_center3 = NSNotificationCenter.defaultCenter
    @notification_center3.addObserver(self,
                                      selector:'readCompletedDataDeleteRecord:',
                                      name:NSFileHandleReadToEndOfFileCompletionNotification,
                                      object:@outputPipe3.fileHandleForReading)

    @outputPipe3.fileHandleForReading.readToEndOfFileInBackgroundAndNotify
    @task_data3.launch

  end

  def readCompletedDataDeleteRecord(notification)
    sync_exact_data
  end

  def record_window(record_data=nil)

    if @record_window_controller && @record_window_controller.window.isVisible

      alert = NSAlert.new
      alert.messageText = "Can't edit 2 records at the same time"
      alert.runModal

    else
      @record_window_controller = nil
      @record_window_controller ||= RecordWindowController.alloc.init_with_meta(self, @meta, record_data)
    end
  end

  def showhide_window
    @showhide_window_controller ||= ShowHidePrefsWindowController.alloc.init_with_meta(self, @meta)
    @showhide_window_controller.showWindow(self)
    @showhide_window_controller.window.orderFrontRegardless
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

    DJProgressHUD.showStatus("talking to Exact", FromView:@outer_view)

    @task_data = NSTask.alloc.init

    @task_data.setLaunchPath "/Users/pim/RnD/exact-online-kitchensink/bin/eo"
    @task_data.setCurrentDirectoryPath "/Users/pim/RnD/exact-online-kitchensink"
    @task_data.setArguments([@end_point.underscore, 'jsonlist', '-C'])

    @outputPipe = NSPipe.pipe
    @task_data.setStandardOutput @outputPipe

    @notification_center = NSNotificationCenter.defaultCenter
    @notification_center.addObserver(self, selector:'readCompletedData:', name:NSFileHandleReadToEndOfFileCompletionNotification, object:@outputPipe.fileHandleForReading)

    @outputPipe.fileHandleForReading.readToEndOfFileInBackgroundAndNotify
    @task_data.launch
  end

  def readCompletedData(notification)
    @sync_done = true
    result = notification.userInfo.objectForKey(NSFileHandleNotificationDataItem)
    @data_org = BW::JSON.parse result
    @data = @data_org

    NSNotificationCenter.defaultCenter.removeObserver(self, name: NSFileHandleReadToEndOfFileCompletionNotification, object: notification.object)
    filter
    DJProgressHUD.dismiss
  end

  def get_record_data(record_id)
    DJProgressHUD.showStatus("talking to Exact", FromView:@outer_view)
    @task_data2 = NSTask.alloc.init
    @task_data2.setLaunchPath "/Users/pim/RnD/exact-online-kitchensink/bin/eo"
    @task_data2.setCurrentDirectoryPath "/Users/pim/RnD/exact-online-kitchensink"
    @task_data2.setArguments([@end_point.underscore, 'jsonlist', '-f', "id=#{record_id}", '-C'])

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

    DJProgressHUD.dismiss
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

    defaults = NSUserDefaults.standardUserDefaults
    @showhide_arr = defaults.objectForKey("showhide_#{@meta['end_point']}")

    text_field.stringValue = row[column.identifier.to_sym].to_s

    return text_field
  end

  def tableViewColumnDidResize(notification)
  end
end
