//
//  NewsDescriptionViewController.swift
//  News
//
//  Created by Илья Ершов on 05/11/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//

import UIKit
import SafariServices

class NewsDescriptionViewController: UIViewController {

    // MARK: - Variables
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fullText: UITextView!
    @IBOutlet weak var pubDateLabel: UILabel!
    
    var rssItem: RSSItem?
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillViews()
    }
    
    func fillViews() {
        guard let imageURL = URL( string: rssItem!.imageURL ) else { return }
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.newsImage.image = image
                }
            }
        }.resume()
        
        pubDateLabel.text = rssItem?.pubDate
        titleLabel.text = rssItem?.title
        fullText.text = rssItem?.fullText
        
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel.sizeToFit()

        fullText.translatesAutoresizingMaskIntoConstraints = true
        fullText.sizeToFit()
    }
    
    @IBAction func shareButton(_ sender: Any) {
        let acticityVC = UIActivityViewController(activityItems: [rssItem!.link], applicationActivities: nil)
        acticityVC.popoverPresentationController?.sourceView = self.view
        self.present(acticityVC, animated: true, completion: nil)
    }
    
    @IBAction func linkButton(_ sender: Any) {
        let url = URL(string: rssItem!.link)!
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
