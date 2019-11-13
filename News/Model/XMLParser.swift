//
//  XMLParser.swift
//  News
//
//  Created by Илья Ершов on 04/11/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//

import Foundation

enum Months: String {
    case jan = "Jan"
    case feb = "Feb"
    case mar = "Mar"
    case apr = "Apr"
    case may = "May"
    case jun = "Jun"
    case jul = "Jul"
    case aug = "Aug"
    case sep = "Sep"
    case oct = "Oct"
    case nov = "Nov"
    case dec = "Dec"
}

struct RSSItem: Codable {
    let title: String
    let description: String
    let pubDate: String
    let imageURL: String
    let category: String
    let fullText: String
    let link: String
}

class FeedParser: NSObject, XMLParserDelegate {
    private var rssItems: [RSSItem] = []
    private var currentElement: String = ""
    private var currentTitle: String = ""
    private var currentDescription: String = ""
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
    private var currentFullText: String  = ""
    private var currentLink: String  = "" {
        didSet{
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var parserComplitionHandler: (([RSSItem]) -> Void)?
    
    func dateFormater(pubDate date: String) -> String? {
        var formatedDate: String?
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ssZ"
        
        if let date = formatter.date(from: date) {
            let myFormatter = DateFormatter()
            myFormatter.dateFormat = "d MMM HH:mm"
            formatedDate = myFormatter.string(from: date)
            
            let start = formatedDate!.index(formatedDate!.startIndex, offsetBy: 3)
            let end = formatedDate!.index(formatedDate!.startIndex, offsetBy: 6)
            let range = start..<end

            let mySubstring = formatedDate![range]
            formatedDate?.removeSubrange(range)
            
            var res: String?
            res = formatedDate
            switch (String(mySubstring)) {
                case Months.jan.rawValue:
                    res?.insert(contentsOf:"Января", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.feb.rawValue: res?.insert(contentsOf:"Февраля", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.mar.rawValue: res?.insert(contentsOf:"Марта", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.apr.rawValue: res?.insert(contentsOf:"Апреля", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.may.rawValue: res?.insert(contentsOf:"Мая", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.jun.rawValue: res?.insert(contentsOf:"Июня", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.jul.rawValue: res?.insert(contentsOf:"Июля", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.aug.rawValue: res?.insert(contentsOf:"Августа", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.sep.rawValue: res?.insert(contentsOf:"Сентября", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.oct.rawValue: res?.insert(contentsOf:"Октября", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.nov.rawValue: res?.insert(contentsOf:"Ноября", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                case Months.dec.rawValue: res?.insert(contentsOf:"Декабря", at: (formatedDate?.index(formatedDate!.startIndex, offsetBy: 3))!)
                default:
                    return date.description
            }
            formatedDate = res
        }
        return formatedDate
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
                if let date = dateFormater(pubDate: string) {
                    currentPubDate += date
                } else {
                    currentPubDate += string
                }
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
