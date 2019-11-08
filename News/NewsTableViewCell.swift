//
//  NewsTableViewCell.swift
//  News
//
//  Created by Илья Ершов on 04/11/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var item: RSSItem! {
        didSet {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            titleLabel.text = item.title
            pubDateLabel.text = item.pubDate
            
            guard let imageURL = URL( string: item.imageURL ) else { return }
            URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.hidesWhenStopped = true
                        self.newsImage.image = image
                    }
                }
            }.resume()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
