//
//  ItemListViewModel.swift
//  MIndTechTest
//
//  Created by Tnluser on 06/02/23.
//

import UIKit

class ItemListViewModel {

    var itemList: ItemListDataModel?
    var reloadData : (() -> ()) = {}
    var selectedItemList: [DataList]?
    
    
    func fetchDummyData() {
        let path = Bundle.main.path(forResource: "List", ofType: "json")
        if let path = path {
            let data = NSData(contentsOfFile: path)
            let jsonDecoder = JSONDecoder()
            do {
                if let listData = data as? Data {
                    let modelList = try jsonDecoder.decode(ItemListDataModel.self, from: listData)
                    self.itemList = modelList
                    self.reloadData()
                }
            }
            catch _ {
            }
        }
    }
}
