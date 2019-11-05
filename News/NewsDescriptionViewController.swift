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

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fullText: UITextView!
    @IBOutlet weak var pubDateLabel: UILabel!
    
    var rssItem: RSSItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillViews()
        
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping

        fullText.translatesAutoresizingMaskIntoConstraints = true
        fullText.sizeToFit()

//        var frame = fullText.frame
//        frame.size.height = fullText.contentSize.height
//        fullText.frame = frame
        
    }
    
    @IBAction func linkButton(_ sender: Any) {
        let url = URL(string: rssItem!.link)!
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
        
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
