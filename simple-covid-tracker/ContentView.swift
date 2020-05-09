//
//  ContentView.swift
//  simple-covid-tracker
//
//  Created by Matthew Kim on 5/4/20.
//  Copyright © 2020 Matthew Kim. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

struct ContentView: View {
    @State private var selection = 0
    @ObservedObject var list = getNewsData()
    
    var body: some View {
        TabView(selection: $selection){
            Home()
                .tabItem {
                    VStack {
                        Image("first")
                        Text("Statistics")
                    }
                }
                .tag(0)
            NewsView()
                .tabItem {
                    VStack {
                        Image("second")
                        Text("News")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct dataType : Identifiable {
    
    var id : String
    var title : String
    var desc : String
    var url : String
    var image : String
}

class getNewsData : ObservableObject {
    
    @Published var datas = [dataType]()
    
    init() {
        //https://newsapi.org/v2/top-headlines?country=us&q=coronavirus&apiKey=92729bacd8ed4c2b8f3ad9d5d9669fbc
        //https://newsapi.org/v2/everything?country=us&q=mma&apiKey=92729bacd8ed4c2b8f3ad9d5d9669fbc
        let source = "https://newsapi.org/v2/everything?q=coronavirus&language=en&apiKey=92729bacd8ed4c2b8f3ad9d5d9669fbc"
        let url = URL(string: source)!
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { (data, _, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            let json = try! JSON(data: data!)
            
            for i in json["articles"]{
    
                let title = i.1["title"].stringValue
                let description = i.1["descrption"].stringValue
                let url = i.1["url"].stringValue
                let image = i.1["urlToImage"].stringValue
                let id = i.1["publishedAt"].stringValue

                
                DispatchQueue.main.async {
                    self.datas.append(dataType(id: id, title: title, desc: description, url: url, image: image))
                }
                
                
            }
            
        }.resume()
    }
}

struct webView: UIViewRepresentable {
    
    var url : String
    
    func makeUIView(context: UIViewRepresentableContext<webView>) ->
        WKWebView {
        let view = WKWebView()
            view.load(URLRequest(url: URL(string: url)!))
            return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
    }
    
}

struct NewsView : View {
    
    @ObservedObject var list = getNewsData()
    
    var body: some View{
        NavigationView {
            List(list.datas) {i in
                
                NavigationLink(destination:
                    
                webView(url: i.url)
                    .navigationBarTitle("", displayMode: .inline)) {
                    HStack(spacing: 15){
                        
                        VStack(alignment: .leading, spacing: 10){
                            Text(i.title).fontWeight(.heavy)
                            Text(i.desc).lineLimit(2)
                        }
                        
                        if i.image != ""{
                            WebImage(url: URL(string: i.image)!, options: .highPriority, context: nil).resizable().frame(width: 110, height: 135).cornerRadius(20)
                        }
                        
                        
                    }.padding(.vertical, 15)
                }
            }.navigationBarTitle("Headlines")
        }
    }

}

struct Home : View {
    
    @State var index = 0
    @State var main : MainData!
    @State var daily : [Daily] = []
    @State var last : Int = 0
    @State var country = "usa"
    @State var alert = false
    
    var body: some View{
        
        VStack{
            
            if self.main != nil && !self.daily.isEmpty {
                
                VStack{
                    VStack(spacing: 18){
                        HStack{
                            Text("Covid-19 Stats")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                
                                self.Dialog()
                                
                            }) {
                                Text(self.country.uppercased())
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 15)
                        
                        
                        HStack{
                            
                            Button(action: {
                                self.index = 0
                                self.main = nil
                                self.daily.removeAll()
                                self.getData()
                            }) {
                                
                                Text("\(self.country)".uppercased())
                                    .foregroundColor(self.index == 0 ? .black : .white)
                                    .padding(.vertical, 12)
                                    .frame(width: (UIScreen.main.bounds.width / 2) - 30)
                            }
                            .background(self.index == 0 ? Color.white : Color.clear)
                            .clipShape(Capsule())
                            
                            Button(action: {
                                self.index = 1
                                self.daily.removeAll()
                                self.main = nil
                                self.getData()
                            }) {
                                
                                Text("Global")
                                    .foregroundColor(self.index == 1 ? .black : .white)
                                    .padding(.vertical, 12)
                                    .frame(width: (UIScreen.main.bounds.width / 2) - 30)
                            }
                            .background(self.index == 1 ? Color.white : Color.clear)
                            .clipShape(Capsule())
                        }
                        
                        .background(Color.black.opacity(0.25))
                        .clipShape(Capsule())
                        .padding(.top, 10)
                        
                        HStack(spacing: 15){
                            VStack(spacing: 12){
                                Text("Affected").fontWeight(.bold)
                                Text("\(self.main.cases)").fontWeight(.bold)
                                    .font(.title)
                            }
                            .padding(.vertical)
                            .frame(width: (UIScreen.main.bounds.width / 2) - 30)
                            .background(Color("affected"))
                            .cornerRadius(12)
                            
                            
                            VStack(spacing: 12){
                                Text("Deaths").fontWeight(.bold)
                                Text("\(self.main.deaths)").fontWeight(.bold).font(.title)
                            }
                            .padding(.vertical)
                            .frame(width: (UIScreen.main.bounds.width / 2) - 30)
                            .background(Color("death"))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.white)
                        .padding(.top, 10)
                        
                        
                        
                        HStack(spacing: 15){
                            VStack(spacing: 12){
                                Text("Recovered")
                                    .fontWeight(.bold)
                                Text("\(self.main.recovered)").fontWeight(.bold)
                            }
                            .padding(.vertical)
                            .frame(width: (UIScreen.main.bounds.width / 3) - 30)
                            .background(Color("recovered"))
                            .cornerRadius(12)
                            
                            
                            VStack(spacing: 12){
                                Text("Active")
                                    .fontWeight(.bold)
                                Text("\(self.main.active)").fontWeight(.bold)
                            }
                            .padding(.vertical)
                            .frame(width: (UIScreen.main.bounds.width / 3) - 30)
                            .background(Color("active"))
                            .cornerRadius(12)
                            
                            VStack(spacing: 12){
                                Text("Serious")
                                    .fontWeight(.bold)
                                Text("\(self.main.critical)").fontWeight(.bold)
                                    
                            }
                            .padding(.vertical)
                            .frame(width: (UIScreen.main.bounds.width / 3) - 30)
                            .background(Color("serious"))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.white)
                        .padding(.top, 10)
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 45)
                    .background(Color("bg"))
                    
                    VStack(spacing: 15){
                        HStack{
                            Text("Last 7 Days")
                                .font(.title)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.top)
                        
                        HStack{
                            ForEach(self.daily){i in
                                
                                VStack(spacing: 10){
                                    
                                    Text("\(i.cases / 1000)K")
                                        .lineLimit(1)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    GeometryReader{g in
                                        VStack{
                                            Spacer(minLength: 0)
                                            Rectangle()
                                            .fill(Color("death"))
                                                .frame(width: 15, height: self.getHeight(value: i.cases, height: g.frame(in: .global).height))
                                        }
                                    }
                                    
                                    Text(i.day)
                                        .lineLimit(1)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.bottom, -30)
                    .offset(y: -30)
                }
            }
            else {
                
                Indicator()
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        .alert(isPresented: self.$alert, content: {
            
            Alert(title: Text("Error"), message: Text("Invalid Country Name"), dismissButton: .destructive(Text("Ok")))
            
        })
        .onAppear {
            if self.daily.isEmpty {
                self.daily.removeAll()
                self.getData()
            }
            
        }
    }

    func getData() {
        var url = ""
        
        if self.index == 0 {
            url = "https://corona.lmao.ninja/v2/countries/\(self.country)?yesterday=false"
        } else {
            url = "https://corona.lmao.ninja/v2/all?today"
        }
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            let json = try! JSONDecoder().decode(MainData.self, from: data!)
            
            self.main = json
        }
        .resume()
        
        var url1 = ""
        
        if self.index == 0 {
            
            url1 = "https://corona.lmao.ninja/v2/historical/\(self.country)?lastdays=7"
            
        } else {
            url1 = "https://corona.lmao.ninja/v2/historical/all?lastdays=7"
        }
        
        let session1 = URLSession(configuration: .default)
        
        session1.dataTask(with: URL(string: url1)!) { (data, _, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            var count = 0
            var cases: [String : Int] = [:]
            
            if self.index == 0{
                let json = try! JSONDecoder().decode(MyCountry.self, from: data!)
                    
                cases = json.timeline["cases"]!
            } else {
                let json = try! JSONDecoder().decode(Global.self, from: data!)
                cases = json.cases
            }
            for i in cases {
                
                self.daily.append(Daily(id: count, day: i.key, cases: i.value))
                count += 1
            }

            self.daily.sort { (t, t1) -> Bool in
                
                if t.day < t1.day {
                    return true
                } else {
                    
                    return false
                    
                }
            }
            
            self.last = self.daily.last!.cases
        }
    .resume()
    }
    
    func getHeight(value : Int, height: CGFloat)->CGFloat {
                
        if self.last != 0 {
            let converted = CGFloat(value) / CGFloat(self.last)
                               
            return converted * height
        } else {
            return 0
        }
    }
    
    func Dialog() {
        
        let alert = UIAlertController(title: "Country", message: "Type A Country", preferredStyle: .alert)
        
        alert.addTextField { (_) in
            
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            
            for i in countryList {
                if i.lowercased() == alert.textFields![0].text!.lowercased() {
                    
                    self.country = alert.textFields![0].text!.lowercased()
                    self.main = nil
                    self.daily.removeAll()
                    self.getData()
                    return
                }
            }
            
            self.alert.toggle()
            
        }))
           
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
}

class Host : UIHostingController<ContentView> {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

struct Daily: Identifiable {
    
    var id : Int
    var day : String
    var cases : Int
}

struct MainData : Decodable {
    
    var deaths : Int
    var recovered : Int
    var active : Int
    var critical : Int
    var cases : Int
}

struct MyCountry : Decodable {
    
    var timeline : [String : [String : Int]]
}

struct Global : Decodable {
    var cases : [String : Int]
}

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
    
}
