//
//  XMLParser.swift
//  News
//
//  Created by Илья Ершов on 04/11/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//

import Foundation

struct RSSItem: Codable {
    let title: String
    let description: String
    let pubDate: String
    let imageURL: String
    let category: String // Происшествия, спорт, общество, в мире, политика, Вести.Недвижимость
    let fullText: String //yandex:full-text
    let link: String //link to the sourse
}

class FeedParser: NSObject, XMLParserDelegate {
    private var rssItems: [RSSItem] = []
    private var currentElement: String = ""
    
    private var currentTitle: String = "" {
        didSet{
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDescription: String = "" {
        didSet{
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate: String  = "" {
        didSet{
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentImageURL: String  = "" {
        didSet{
            currentImageURL = currentImageURL.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentCategory: String  = "" {
        didSet{
            currentCategory = currentCategory.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentFullText: String  = "" {
        didSet{
            currentFullText = currentFullText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentLink: String  = "" {
        didSet{
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var parserComplitionHandler: (([RSSItem]) -> Void)?
    
    //TODO: - DATE FORMATTER
    func dateFormater(pubDate date: String) {
        let formater = DateFormatter()
        formater.dateFormat = "E, d MMM yyyy HH:mm:ss zzzz"
        //formater.dateFormat = "yyyy-MM-dd HH:mm"
        print(date)

        //formater.locale = Locale(identifier: "ru_RU")
        let date1 = formater.date(from: date)
        print(date1)
        
    }
    
    func parseFeed(url: String, complitionHandler: (([RSSItem]) -> Void)?) {
        self.parserComplitionHandler = complitionHandler
        
        guard let url = URL(string: url) else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
             
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }.resume()
    }
    
    //MARK: - XML Parser Delegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        switch currentElement {
            case "item":
                currentTitle = ""
                currentDescription = ""
                currentPubDate = ""
                currentImageURL = ""
                currentCategory = ""
                currentFullText = ""
                currentLink = ""
            case "enclosure":
                if let urlString = attributeDict["url"] {
                    currentImageURL += urlString
                } else {
                    print("malformed element: enclosure without url attribute")
                }
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title": currentTitle += string
            case "description": currentDescription += string
            case "pubDate":
                //dateFormater(pubDate: string)
                currentPubDate += string
            case "category": currentCategory += string
            case "enclosure": currentImageURL += string
            case "yandex:full-text": currentFullText += string
            case "link": currentLink += string
            default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSItem(title: currentTitle, description: currentDescription, pubDate: currentPubDate, imageURL: currentImageURL, category: currentCategory, fullText: currentFullText, link: currentLink)
            self.rssItems.append(rssItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserComplitionHandler?(rssItems)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription )
    }
}
