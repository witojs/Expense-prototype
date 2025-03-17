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
    var onUpdate: (ExpenseItem) -> Void
    @State private var selectedExpense: ExpenseItem?
    //delete using alertBox
    @State private var expenseToDelete: UUID?
    @State private var showAlert = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
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
                                Divider()
                                //Note: By default list will trigger the button if tapped, to solve add .buttonStyle(PlainButtonStyle()) modifier
                                Button(action:{
                                    onDelete(item.id)
//                                    expenseToDelete = item.id
//                                    showAlert = true
                                    dismiss()
                                    
                                }){
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Button(action: {
                                    selectedExpense = item
                                }){
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
        }
//        .alert("Confirm Deletion", isPresented: $showAlert){
//            Button("Delete", role: .destructive){
//                if let id = expenseToDelete{
//                    onDelete(id)
//                    print("Delete item with id \(id)")
//                }
//            }
//            Button("Cancel", role: .cancel){}
//        } message: {
//            Text("Are you sure want to delete this expense?")
//        }
        .sheet(item: $selectedExpense){ expenseToEdit in
            EditView(expense: expenseToEdit, onUpdate: updateExpense)
        }
    }
    
    private func updateExpense(updatedExpense: ExpenseItem){
        onUpdate(updatedExpense)
    }
    
}

#Preview {
    DetailView(
        category: "Personal",
        expenses: [
            ExpenseItem(
                title: "Groceries",
                category: "Personal",
                amount: 50.0,
                date: Date(),
                note: "Belanja Bulanan"
            ),
            ExpenseItem(
                title: "Utilities",
                category: "Personal",
                amount: 150.0,
                date: Date(),
                note: nil
            ),
            ExpenseItem(
                title: "Rent",
                category: "Personal",
                amount: 1200.0,
                date: Date(),
                note: nil
            )
        ],
        onDelete: {_ in
        },
        onUpdate: {_ in})
}
