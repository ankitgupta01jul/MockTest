//
//  ItemListViewController.swift
//  MIndTechTest
//
//  Created by Tnluser on 06/02/23.
//

import UIKit

class ItemListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headarSearchView: UIView!

    var viewModel = ItemListViewModel()
    var scrolIndex = 0
    var resultSearchController = UISearchController()

    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        self.arrVMListners()
        viewModel.fetchDummyData()
        self.registerCells()
    }
    
    // MARK: - Helper Methods
    private func registerCells() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        tableView.register(UINib(nibName: "ImageAndTextTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageAndTextTableViewCell")
    }
    
    func initialSetup() {
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.barStyle = UIBarStyle.black
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.backgroundColor = UIColor.white
            //controller.view.backgroundColor = UIColor.white
            controller.showsSearchResultsController = true
            self.tableView.tableHeaderView?.subviews[2].addSubview(controller.searchBar) //= controller.searchBar
            return controller
        })()
        self.tableView.reloadData()
    }

    private func arrVMListners() {
        self.viewModel.reloadData = {
            DispatchQueue.main.async {
                self.pageControl.numberOfPages = self.viewModel.itemList?.list?.count ?? 0
                self.pageControl.currentPage = 0
                self.scrolIndex = 0
                if let list =  self.viewModel.itemList?.list, list.count > 0 {
                    self.viewModel.selectedItemList = list.first?.dataList
                }
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - CollectionView Delegates & DataSource

extension ItemListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.viewModel.itemList?.list?.count {
            return count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
        return cell
    }
}

extension ItemListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 32, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int)-> UIEdgeInsets{
        return UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }

}

extension ItemListViewController: UIScrollViewDelegate{
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == collectionView {
            targetContentOffset.pointee = scrollView.contentOffset
            var indexes = self.collectionView.indexPathsForVisibleItems
            indexes.sort()
            var index = indexes.first!
            let cell = self.collectionView.cellForItem(at: index)!
            let position = self.collectionView.contentOffset.x - cell.frame.origin.x
            if position > cell.frame.size.width/2{
                index.row = index.row+1
            }
            self.collectionView.scrollToItem(at: index, at: .left, animated: true )
            pageControl.currentPage = index.row
            scrolIndex  = index.row
            if let list = self.viewModel.itemList?.list {
                self.viewModel.selectedItemList = list[scrolIndex].dataList
                self.tableView.reloadData()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            let value = scrollView.contentOffset.y
            let headerViews = self.tableView.tableHeaderView?.subviews
            if headerViews?.count ?? 0 > 1 {
                let tableHeaderView = self.tableView.tableHeaderView?.subviews[2]
                if (value > 210) {
                    tableHeaderView?.transform = CGAffineTransformMakeTranslation(0, value - 210);
                } else{
                    tableHeaderView?.transform = CGAffineTransformMakeTranslation(0, 0);
                }
            }
        }
    }
}


// MARK: - UITableViewDataSource and Delegate
extension ItemListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.viewModel.selectedItemList {
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageAndTextTableViewCell", for: indexPath) as? ImageAndTextTableViewCell
        cell?.selectionStyle = .none
        if let list =  self.viewModel.selectedItemList {
            let model =  list[indexPath.row]
            cell?.cellImageView.image = UIImage(named: model.imageName ?? "")
            cell?.cellLabel.text = model.title
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
    }
}

extension ItemListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        self.filterContentForSearchText(text)
        self.tableView.reloadData()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        
        if let list = self.viewModel.itemList?.list {
            let model =  list[scrolIndex].dataList
            if searchText.count == 0 {
                self.viewModel.selectedItemList = model
            } else {
                self.viewModel.selectedItemList = model?.filter({ (modelData:DataList) -> Bool in
                    let titleMatch = modelData.title!.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                    return titleMatch != nil })
            }
        }
    }
}
