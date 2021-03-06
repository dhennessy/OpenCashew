//
//  SearchSuggestionViewController.swift
//  Issues
//
//  Created by Hicham Bouabdallah on 6/17/16.
//  Copyright © 2016 SimpleRocket LLC. All rights reserved.
//

import Cocoa

class SearchSuggestionViewController: NSViewController {
    
    @IBOutlet weak var tableViewScrollView: BaseScrollView!
    @IBOutlet weak var tableView: BaseTableView!
    
    private let dataSource = SearchSuggestionDataSource()
    private let valueTableViewAdapter = SuggestionValueTableViewAdaptor()
    
    var searchQuery: String? {
        didSet {
            didSetSearchQuery()
        }
    }
    var onSuggestionClick: dispatch_block_t?
    var onDataReload: dispatch_block_t?
    
    deinit {
        ThemeObserverController.sharedInstance.removeThemeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.target = self;
        tableView.action = #selector(SearchSuggestionViewController.didClickRow(_:));
        tableView.intercellSpacing = NSSize.zero
        tableView.registerAdapter(valueTableViewAdapter, forClass: SearchSuggestionResultItemValue.self)
        tableView.registerAdapter(SuggestionHeaderTableViewAdaptor(), forClass: SearchSuggestionResultItemHeader.self)
        tableView.registerAdapter(BaseSpacerTableViewAdapter(), forClass: BaseSpacerTableRowViewItem.self)
        
        if (.Dark == NSUserDefaults.themeMode()) {
            let appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            tableView.appearance = appearance;
        } else {
            let appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            tableView.appearance = appearance;
        }
        
        tableView.disableThemeObserver = true
        if let view = self.view as? BaseView {
            view.disableThemeObserver = true
        }
        
        ThemeObserverController.sharedInstance.addThemeObserver(self) { [weak self] (mode) in
            guard let strongSelf = self, view = strongSelf.view as? BaseView else { return }
            
            if mode == .Dark {
                strongSelf.tableView.backgroundColor = DarkModeColor.sharedInstance.popoverBackgroundColor()
                view.backgroundColor = strongSelf.tableView.backgroundColor
            } else {
                strongSelf.tableView.backgroundColor = LightModeColor.sharedInstance.backgroundColor()
                view.backgroundColor = strongSelf.tableView.backgroundColor
            }
        }
    }
    
    @objc
    private func didClickRow(sender: AnyObject) {
        if let onSuggestionClick = onSuggestionClick {
            onSuggestionClick()
        }
    }
    
    var calculatedHeight: CGFloat {
        get {
            var windowHeight: CGFloat = 0
            for i in 0 ..< dataSource.resultCount {
                let item = dataSource.resultAtIndex(i)
                let rowHeight = tableView.heightForItem(item, row: i)
                //DDLogDebug("item \(i) height = \(rowHeight)")
                windowHeight += rowHeight
            }
          //  DDLogDebug("total Height = \(windowHeight)")
            return windowHeight
           // return self.tableViewScrollView.documentView?.bounds.height ?? 0;
        }
    }
    
    private func didSetSearchQuery() {
        guard let searchQuery = searchQuery else { return }
        dataSource.searchUsingQuery(searchQuery) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
            if let onDataReload = strongSelf.onDataReload {
                onDataReload()
            }
        }
    }
    
    // MARK: Control keyboard selection
    func moveUp() {
        if tableView.selectedRow == -1 {
            tableView.selectRowIndexes(NSIndexSet(index:self.dataSource.resultCount-2), byExtendingSelection: false)
        } else {
            var nextRow = Int(tableView.selectedRow - 1)
            while (!tableView(tableView, shouldSelectRow:nextRow) && nextRow >= 0) {
                nextRow = Int(nextRow - 1)
            }
            if nextRow > 0 {
                tableView.selectRowIndexes(NSIndexSet(index:nextRow), byExtendingSelection: false)
            }
        }
    }
    
    func moveDown() {
        if tableView.selectedRow == -1 {
            tableView.selectRowIndexes(NSIndexSet(index:2), byExtendingSelection: false)
        } else {
            var nextRow = Int(tableView.selectedRow + 1)
            while (nextRow > 0 && nextRow < self.dataSource.resultCount && !tableView(tableView, shouldSelectRow:nextRow)) {
                nextRow = Int(nextRow + 1)
            }
            if nextRow < self.dataSource.resultCount && nextRow > 0 {
                tableView.selectRowIndexes(NSIndexSet(index:nextRow), byExtendingSelection: false)
            }
        }
    }
    
    func currentSearchResultSelection() -> SearchSuggestionResultItemValue? {
        let selectedRow = tableView.selectedRow
        if selectedRow > 0 && selectedRow < self.dataSource.resultCount {
            if let value = self.dataSource.resultAtIndex(selectedRow) as? SearchSuggestionResultItemValue {
                return value
            }
        }
        return nil
    }
}

extension SearchSuggestionViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil;
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if row > dataSource.resultCount - 1 {
            return nil
        }
        
        let item = dataSource.resultAtIndex(row)
        return self.tableView.adaptForItem(item, row: row, owner: self)
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row > dataSource.resultCount - 1 {
            return 0
        }
        
        let item = dataSource.resultAtIndex(row)
        return self.tableView.heightForItem(item, row: row)
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row > dataSource.resultCount - 1 || row == -1 {
            return false
        }
        
        if let _ = dataSource.resultAtIndex(row) as? SearchSuggestionResultItemValue {
            return true
        } else {
            return false
        }
    }
}

extension SearchSuggestionViewController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataSource.resultCount
    }
    
}
