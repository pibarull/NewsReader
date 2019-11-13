//
//  NewsTableViewCell.swift
//  News
//
//  Created by Илья Ершов on 04/11/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    var newsTableVC: NewsTableViewController?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var item: RSSItem! {
        didSet {
            titleLabel.text = item.title
            //TODO: - center alling
            pubDateLabel.text = item.pubDate
            categoryLabel.text = item.category.uppercased()
            
            if item.read {
                titleLabel.alpha = 0.5
            } else {
                titleLabel.alpha = 1
            }
            
            activityIndicator.isHidden = false // Setting an image to the cell
            activityIndicator.startAnimating()
            if let imageURL = URL( string: item.imageURL ) {
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
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let interaction = UIContextMenuInteraction(delegate: self)
        self.contentView.addInteraction(interaction)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

extension NewsTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

            return self.makeContextMenu()
        })
    }
    
    
    func makeContextMenu() -> UIMenu {

        let share = UIAction(title: "Share", image: UIImage(systemName: "arrowshape.turn.up.right")) { action in
            let acticityVC = UIActivityViewController(activityItems: [self.item.link], applicationActivities: nil)
            acticityVC.popoverPresentationController?.sourceView = self.newsTableVC?.view
            self.newsTableVC?.present(acticityVC, animated: true, completion: nil)
        }

        return UIMenu(title: item.description, children: [share])
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        animator.addCompletion {
            self.newsTableVC?.indexOfSelectedRow = self.newsTableVC?.tableView.indexPath(for: self)?.row
            self.newsTableVC?.performSegue(withIdentifier: "toFullNews", sender: nil)
        }
    }
    
}
