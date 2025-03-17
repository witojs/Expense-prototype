//
//  DetailView.swift
//  Expense-prototype
//
//  Created by Wito Irawan on 14/03/25.
//

import SwiftUI

struct DetailView: View {
    var category: String
    var expenses: [ExpenseItem]
    var onDelete: (UUID) -> Void
    
    //update feature:
//    var onUpdate: (ExpenseItem) -> Void
    
    @State private var selectedExpense: ExpenseItem?
    @State private var showingEditSheet = false
    
    var body: some View {
        List{
            let groupedItems = Dictionary(grouping: expenses, by: {$0.date})
            
            ForEach(groupedItems.keys.sorted(), id: \.self){ date in
                Section(header: Text(date, format: .dateTime.day().month().year())){
                    ForEach(groupedItems[date]!){ item in
                        HStack{
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                if let note = item.note, !note.isEmpty {
                                    Text(note)
                                        .font(.footnote)
                                }
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            Button(action:{
                                onDelete(item.id)
                            }){
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            Button(action: {
                                selectedExpense = item
                                showingEditSheet = true
                            }){
                                Image(systemName: "pencil")
                            }
                            }
                    }
                }
            }
        }
    }
    
}

#Preview {
    DetailView(category: "Personal", expenses: [ExpenseItem(title: "Groceries", category: "Personal", amount: 50.0, date: Date(), note: "Belanja Bulanan"),ExpenseItem(title: "Utilities", category: "Personal", amount: 150.0, date: Date(), note: nil),ExpenseItem(title: "Rent", category: "Personal", amount: 1200.0, date: Date(), note: nil)], onDelete: {_ in })
}
