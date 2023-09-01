//
//  InfoChunithmTicketList.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/8/31.
//

import SwiftUI

struct InfoChunithmTicketList: View {
    var tickets: [CFQChunithm.ExtraEntry.TicketEntry]
    
    var body: some View {
        Form {
            Section {
                ForEach(tickets, id: \.name) { ticket in
                    InfoChunithmTicketItem(ticket: ticket)
                }
            } header: {
                Text("共\(tickets.reduce(0) { $0 + $1.count })张功能票")
            }
        }
        .navigationTitle("功能票列表")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoChunithmTicketItem: View {
    @Environment(\.managedObjectContext) var context
    var ticket: CFQChunithm.ExtraEntry.TicketEntry
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: ticket.url)!, context: context, placeholder: {
                ProgressView()
            }, image: { img in
                Image(uiImage: img)
                    .resizable()
            })
            .aspectRatio(contentMode: .fit)
            .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(ticket.name)
                Text(ticket.description)
                    .font(.system(size: 10))
                    .lineLimit(3)
            }
            Spacer()
            VStack {
                Text("数量")
                Text("\(ticket.count)")
                    .font(.system(size: 16))
                    .bold()
            }
        }
        .frame(height: 60)
    }
}
