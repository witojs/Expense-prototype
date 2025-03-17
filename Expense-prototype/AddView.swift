//
//  AddView.swift
//  Expense-prototype
//
//  Created by Wito Irawan on 14/03/25.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var category = "Personal"
    @State private var amount = 0.0
    @State private var date = Date.now
    @State private var note = ""
    
    var expense: Expenses
    
    let categories = ["Personal", "Business", "Travel", "Education"]
    
    //TODO: add Validation Form
    var body: some View {
        NavigationStack {
            Form{
                TextField("Title", text: $title)
                Picker("Category", selection: $category){
                    ForEach(categories, id:\.self){
                        Text($0)
                    }
                }
                DatePicker("Select a Date", selection: $date, in: yesterday...Date.now, displayedComponents: .date)
                TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD")).keyboardType(.decimalPad)
                VStack {
                    TextField("Note - opsional", text: $note)
                        .onChange(of: note){
                            if note.count > 50{
                                note = String(note.prefix(50))
                            }
                        }
                    
                    HStack {
                        Spacer()
                        Text("\(note.count)/50")
                            .foregroundStyle(characterColor)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("Save"){
                    let item = ExpenseItem(title: title, category: category, amount: amount, date: formatDate(date), note: note)
                    expense.items.append(item)
                    dismiss()
                }
            }
        }
    }
    
    //set least date to input expense, in this case 2 days before today
    private var yesterday: Date{
        Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
    }
    
    private func formatDate(_ date: Date) -> Date{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
    
    //setting color for max char
    private var characterColor: Color{
        let remaining = 50 - note.count
        if remaining < 5 {
            return .red
        } else {
            return .gray
        }
    }
}

#Preview {
    AddView(expense: Expenses())
}
