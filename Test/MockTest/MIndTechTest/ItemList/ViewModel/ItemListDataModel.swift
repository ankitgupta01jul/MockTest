//
//  ItemListDataModel.swift
//  MIndTechTest
//
//  Created by Tnluser on 06/02/23.
//

import UIKit


// MARK: - Welcome
class ItemListDataModel: Codable {
    let list: [List]?

    init(list: [List]?) {
        self.list = list
    }
}

// MARK: - List
class List: Codable {
    let imageName: String?
    let dataList: [DataList]?

    init(imageName: String?, dataList: [DataList]?) {
        self.imageName = imageName
        self.dataList = dataList
    }
}

// MARK: - Datum
class DataList: Codable {
    let imageName, title: String?

    init(imageName: String?, title: String?) {
        self.imageName = imageName
        self.title = title
    }
}
