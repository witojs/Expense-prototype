//
//  EditView.swift
//  Expense-prototype
//
//  Created by Wito Irawan on 17/03/25.
//

import SwiftUI

struct EditView: View {
    var expense: ExpenseItem
    var onUpdate: (ExpenseItem) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var category: String
    @State private var amount: Double
    @State private var note: String?
    
    let categories = ["Personal", "Business", "Travel", "Education"]
    
    //initialize the data, so when opened the textfield filled with expense data
    init(
        expense: ExpenseItem,
        onUpdate: @escaping (ExpenseItem) -> Void
    ) {
        self.expense = expense
        self.onUpdate = onUpdate
        _title = State(initialValue: expense.title)
        _category = State(initialValue: expense.category)
        _amount = State(initialValue: expense.amount)
        _note = State(initialValue: expense.note)
        print(expense)
    }
    
    //using custom binding because note data is optional, custom binding provide default value if note is nil
    private var noteBinding: Binding<String> {
        Binding<String>(
            get: {note ?? ""}, set: {note = $0.isEmpty ? nil : $0}
        )
    }
    
    var body: some View {
        NavigationStack {
            Form{
                TextField("Title", text: $title)
                Picker("Category", selection: $category){
                    ForEach(categories, id:\.self){
                        Text($0)
                    }
                }
                TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD")).keyboardType(.decimalPad)
                VStack {
                    TextField(
                        "Note - opsional",
                        text: noteBinding
                    )
                    .onChange(of: note){
                        if noteBinding.wrappedValue.count > 50{
                            note = String(note!.prefix(50))
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Text("\(noteBinding.wrappedValue.count)/50")
                            .foregroundStyle(characterColor)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("Update"){
                    let updatedExpense = ExpenseItem(
                        id: expense.id,
                        title: title,
                        category: category,
                        amount: amount,
                        date: expense.date,
                        note: note
                    )
                    print(updatedExpense)
                    onUpdate(updatedExpense)
                    dismiss()
                    print("note binding is \(noteBinding)")
                }
            }
        }
    }
    
    private var characterColor: Color{
        let remaining = 50 - noteBinding.wrappedValue.count
        if remaining < 5 {
            return .red
        } else {
            return .gray
        }
    }
}

#Preview {
    let sampleExpense = ExpenseItem(title: "Groceries", category: "Personal", amount: 50.0, date: Date(), note: "Weekly shopping")
    
    EditView(
        expense: sampleExpense,
        onUpdate: {_ in
        })
}
