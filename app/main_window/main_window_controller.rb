class MainWindowController < NSWindowController
  def layout
    @layout ||= MainWindowLayout.new
  end

  def expand_menu
    @outline_view.expandItem(nil, expandChildren:true)
  end

  def init
    super.tap do
      self.window = layout.window
    end

    build_navigation

    @outline_view = @layout.get(:outline_view)
    @outline_view.outlineTableColumn = @layout.outline_view_column
    @outline_view.delegate = self
    @outline_view.dataSource = self
  end

  def build_navigation
#    children = []
    @instances = {}

    #@visible_resources = ['Projects', 'TimeTransactions', 'Accounts']

    tree = NSApplication.sharedApplication.delegate.api_meta

    services = {}
    tree.each do  | k,v |
      services[v['service']] = {'Title'=> v['service'], 'Children' => []}
    end

    tree.each do  | k,v |
      @instances[k] = ListViewController.new(k)
      services[v['service']]['Children'] << @instances[k].object_entry
    end
#    p tree

    services_tree = []
    services.each do |k,v|
      services_tree << v
    end


    @displayItem = {
      "Title" => 'Exact Online Resources',
      "Children" => services_tree
    }

    p @displayItem

  end

  def outlineView _, numberOfChildrenOfItem: item
    item.nil? ? 1 : item["Children"].length
  end

  def outlineViewSelectionDidChange(notification)
    selected_item = @outline_view.itemAtRow(@outline_view.selectedRow)

    @layout.clear_right_view
    if selected_item['subview']

      right_view = @layout.get(:right_view)
      selected_item['subview'].setFrame right_view.bounds

      @layout.set_right_sub_view selected_item['subview']
      @instances[selected_item['EndPoint']].init_sync
    end
  end

  def outlineView(outlineView, isItemExpandable:item)
    item.nil? ? false : (item["Children"].nil? ? false : item["Children"].length != 0)
  end

  def outlineView(outlineView, child:index, ofItem:item)
    item.nil? ? @displayItem : item["Children"][index]
  end

  def outlineView _, objectValueForTableColumn: column, byItem: item
    if item["Title"].nil?
      @root_item = item
      "Root"
    else
      item["Title"]
    end
  end

end
