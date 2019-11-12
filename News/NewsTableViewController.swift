//
//  NewsTableViewController.swift
//  News
//
//  Created by Илья Ершов on 04/11/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//
// Ссылка почему переход назад - свайп вниз, а не стрелка назад: https://habr.com/ru/company/ifree/blog/247871/


import UIKit

class NewsTableViewController: UITableViewController {

    private var categoryPicker  = UIPickerView()
    
    private var news: [RSSItem]? // Fetched news
    private var newsToShow: [RSSItem]? // Filtered news
    private var categoryToShow: String = "Всё" // Chosen category to filter by
    private var categorySet: Set<String> = []
    private var categoryArr: [String] = []
    var indexOfSelectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
    }

    @IBAction func refreshControl(_ sender: UIRefreshControl) {

        fetchData()
        sender.endRefreshing()
    }

    private func fetchData() {
        
        let feedPareser = FeedParser()
        feedPareser.parseFeed(url: "http://www.vesti.ru/vesti.rss") { (rssItems) in
            self.news = rssItems
            
            for el in rssItems { // Createing set of categories
                self.categorySet.insert(el.category)
            }
            self.categoryArr = self.categorySet.sorted()
            self.categorySet.removeAll()
            self.categoryArr.insert("Всё", at: 0)
            
            //print(self.categoryToShow)
            if self.categoryToShow == "Всё" { // Creating news to show filtered by category
                self.newsToShow = self.news
            } else {
                self.newsToShow = self.news?.filter{$0.category == self.categoryToShow}
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func filterButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Выберите категорию", message: "", preferredStyle: .alert)

        categoryToShow = "Всё"
        
        categoryPicker = UIPickerView(frame: CGRect(x: 10, y: 60, width: 250, height: 150))
        categoryPicker.dataSource = self
        categoryPicker.delegate = self

        alertController.view.addSubview(categoryPicker)

        let action = UIAlertAction(title: "Найти", style: .default) {
            (alert) in
            
            if self.categoryToShow == "Всё" {
                self.newsToShow = self.news
            } else {
                self.newsToShow = self.news?.filter{$0.category == self.categoryToShow}
            }
            self.tableView.reloadData()
            self.tableView.setContentOffset(.zero, animated: true)
            
        }

        alertController.addAction(action)
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.40)
        alertController.view.addConstraint(height);
        present(alertController, animated: true, completion: nil)
        
    }
    

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let news = newsToShow else {
            return 0
        }
        return news.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell

        cell.newsTableVC = self
        cell.titleLabel?.text = newsToShow![indexPath.item].title
        cell.titleLabel?.numberOfLines = 0
        cell.titleLabel?.lineBreakMode = .byWordWrapping
        
        if let item = newsToShow?[indexPath.item] { // Setting the cell's views
            cell.item = item
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toFullNews" {
            let destination = segue.destination as? NewsDescriptionViewController
            
            let index = self.indexOfSelectedRow ?? tableView.indexPathForSelectedRow!.row
            destination?.rssItem = newsToShow?[index]
            //destination?.rssItem = newsToShow?[tableView.indexPathForSelectedRow!.row]
            
        }
    }

}

extension NewsTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryToShow = categoryArr[row]
        //print(categoryToShow)
    }
}
