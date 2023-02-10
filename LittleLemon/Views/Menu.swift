//
//  Menu.swift
//  LittleLemon
//
//  Created by George Chang on 2023-02-08.
//

import SwiftUI

struct Menu: View {
    @Environment(\.managedObjectContext) private var context
    let persistence = PersistenceController.shared
    @State private var searchText = ""
    
    func getMenuData() {
        PersistenceController.shared.clear()
        
        let urlString = "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json"
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(MenuList.self, from: data) {
                        let menu = decodedData.menu
                        for menu in menu {
                            let dish = Dish(context: context)
                            dish.title = menu.title
                            dish.image = menu.image
                            dish.price = menu.price
                            dish.describ = menu.description
                        }
                        try? context.save()
                    }
                } else if error != nil {
                    print(error?.localizedDescription ?? "Error occurred")
                }
            }
            task.resume()
        }
    }

    
    func buildSortDescriptors() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare))]
    }
    
    func buildPredicate() -> NSPredicate {
        if searchText == "" {
            return NSPredicate(value: true)
        } else {
            return NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                LogoView()
                    .padding(.leading, 65)
                Image("profile")
                    .resizable()
                    .frame(width: 65, height: 65)
                    .aspectRatio(contentMode: .fit)
            }
            VStack {
                HeroView()
                TextField("Search menu", text: $searchText)
                    .background(Color.white)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 20)
            }
            .padding()
            .background(Color(red: 0.29, green: 0.37, blue: 0.34, opacity: 1.00))
            
            VStack {
                Text("Order for Delivery!")
                    .fontWeight(.medium)
                    .font(.system(size: 20))
                    .padding(.horizontal, 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                FilterButton(filterType: "Starter")
                    .padding(.horizontal, 5)
                FilterButton(filterType: "Mains")
                    .padding(.horizontal, 5)
                FilterButton(filterType: "Desserts")
                    .padding(.horizontal, 5)
                FilterButton(filterType: "Drinks")
                    .padding(.horizontal, 5)
            }
            .padding(.top, -5)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Divider()
                .padding(.top, 10)
            
            NavigationStack {
                FetchedObjects(predicate: buildPredicate(), sortDescriptors: buildSortDescriptors()) { (dish: [Dish]) in
                    List {
                        ForEach(dish) { dish in
                            NavigationLink {
                                DetailView()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(dish.title!)
                                            .font(Font.custom("karla", size: 20))
                                            .bold()
                                            .padding(.top, 10)
                                        Spacer()
                                        Text(dish.describ!)
                                            .font(Font.custom("Karla-paragraph", size: 16))
                                            .fontWeight(.regular)
                                            .padding(.bottom, -10)
                                            .padding(.top, -5)
                                        Spacer()
                                        Text("$\(dish.price!)")
                                            .font(Font.custom("karla", size: 16))
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                    let url = URL(string: dish.image ?? "unavailable")
                                    AsyncImage(url: url) { image in image
                                            .image?.resizable()
                                    }                                
                                    .frame(width: 100, height: 100, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear(perform: {
            getMenuData()
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}


