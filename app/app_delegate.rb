class AppDelegate
  attr :main_menu_layout

  def applicationDidFinishLaunching(notification)
    @api_meta = init_meta_data
    @main_menu_layout = MainMenu.new
    NSApp.mainMenu = @main_menu_layout.menu

    @main_controller = MainWindowController.alloc.init
    @main_controller.showWindow(self)
    @main_controller.window.orderFrontRegardless
  end

  def api_meta
    @api_meta
  end

  def resource_meta(end_point)
    @api_meta[end_point]
  end

  def init_meta_data
    file_path = NSBundle.mainBundle.pathForResource('data', ofType: 'json')
    BW::JSON.parse(NSData.dataWithContentsOfFile(file_path))
  end
end
