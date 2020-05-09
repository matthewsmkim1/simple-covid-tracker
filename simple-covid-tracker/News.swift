////
////  News.swift
////  simple-covid-tracker
////
////  Created by Matthew Kim on 5/8/20.
////  Copyright © 2020 Matthew Kim. All rights reserved.
////
//
//import Foundation
//
//struct News : View {
//    
//    @ObservedObject var list = getNewsData()
//    
//    var body: some View{
//        NavigationView {
//            List(list.datas) {i in
//                
//                NavigationLink(destination:
//                    
//                webView(url: i.url)
//                    .navigationBarTitle("", displayMode: .inline)) {
//                    HStack(spacing: 15){
//                        
//                        VStack(alignment: .leading, spacing: 10){
//                            Text(i.title).fontWeight(.heavy)
//                            Text(i.desc).lineLimit(2)
//                        }
//                        
//                        if i.image != ""{
//                            WebImage(url: URL(string: i.image)!, options: .highPriority, context: nil).resizable().frame(width: 110, height: 135).cornerRadius(20)
//                        }
//                        
//                        
//                    }.padding(.vertical, 15)
//                }
//            }.navigationBarTitle("Headlines")
//        }
//    }
//}
//
//class getNewsData : ObservableObject {
//    
//    @Published var datas = [dataType]()
//    
//    init() {
//        //https://newsapi.org/v2/top-headlines?country=us&q=coronavirus&apiKey=92729bacd8ed4c2b8f3ad9d5d9669fbc
//        //https://newsapi.org/v2/everything?country=us&q=mma&apiKey=92729bacd8ed4c2b8f3ad9d5d9669fbc
//        let source = "https://newsapi.org/v2/everything?q=coronavirus&language=en&apiKey=92729bacd8ed4c2b8f3ad9d5d9669fbc"
//        let url = URL(string: source)!
//        let session = URLSession(configuration: .default)
//        
//        session.dataTask(with: url) { (data, _, err) in
//            if err != nil{
//                print((err?.localizedDescription)!)
//                return
//            }
//            let json = try! JSON(data: data!)
//            
//            for i in json["articles"]{
//    
//                let title = i.1["title"].stringValue
//                let description = i.1["descrption"].stringValue
//                let url = i.1["url"].stringValue
//                let image = i.1["urlToImage"].stringValue
//                let id = i.1["publishedAt"].stringValue
//
//                
//                DispatchQueue.main.async {
//                    self.datas.append(dataType(id: id, title: title, desc: description, url: url, image: image))
//                }
//                
//                
//            }
//            
//        }.resume()
//    }
//}
