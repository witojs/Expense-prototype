//
//  DetailView.swift
//  Expense-prototype
//
//  Created by Wito Irawan on 14/03/25.
//

import SwiftUI
//command A, control I utk format code
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
    
    //for filtering data
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showCalendar = false
    
    //custom date picker
    //    @State private var showDatePicker = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        //from gpt
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Total Expenses: \(Decimal(totalExpenses), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                    .font(.headline)
                    .padding(.leading)
                
                // 🔹 Button to Show Calendar
                Button(action: { showCalendar.toggle() }) {
                    HStack {
                        Text("Select Date")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(height: 44)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                }
                .padding()
                
                // 🔹 Show Calendar Only When User Taps Button
                if showCalendar {
                    VStack {
                        HStack {
                            Button(action: { changeMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                            }
                            .padding()
                            
                            Text(currentMonth, format: .dateTime.month().year())
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Button(action: { changeMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                            ForEach(getDaysInMonth(), id: \.self) { date in
                                VStack {
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .fontWeight(selectedDate == date ? .bold : .regular)
                                        .foregroundColor(selectedDate == date ? .white : .primary)
                                        .frame(width: 35, height: 35)
                                        .background(selectedDate == date ? Color.blue : Color.clear)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            selectedDate = date
                                            showCalendar = false // Hide calendar after selection
                                        }
                                    
                                    Text("\(dailyTotals[date] ?? 0)")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                        .padding(2) // Add padding for better spacing
                                        .background(Color.gray.opacity(0.2)) // Light gray background
                                        .cornerRadius(5) // Rounded corners
                                }
                            }
                        }
                        .padding()
                        
                        // 🔹 Close Calendar Button
                        Button("Close") {
                            showCalendar = false
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)).shadow(radius: 5))
                    .padding()
                }
                
                // 🔹 Custom Calendar View with Expenses - okish
                //                VStack {
                //                    HStack {
                //                        Button(action: { changeMonth(by: -1) }) {
                //                            Image(systemName: "chevron.left")
                //                        }
                //                        .padding()
                //
                //                        Text(currentMonth, format: .dateTime.month().year())
                //                            .font(.title2)
                //                            .fontWeight(.bold)
                //
                //                        Button(action: { changeMonth(by: 1) }) {
                //                            Image(systemName: "chevron.right")
                //                        }
                //                        .padding()
                //                    }
                //
                //                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                //                        ForEach(getDaysInMonth(), id: \.self) { date in
                //                            VStack {
                //                                Text("\(Calendar.current.component(.day, from: date))")
                //                                    .fontWeight(selectedDate == date ? .bold : .regular)
                //                                    .foregroundColor(selectedDate == date ? .white : .primary)
                //                                    .frame(width: 35, height: 35)
                //                                    .background(selectedDate == date ? Color.blue : Color.clear)
                //                                    .clipShape(Circle())
                //                                    .onTapGesture {
                //                                        selectedDate = date
                //                                    }
                //
                //                                Text("\(dailyTotals[date] ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                //                                    .font(.caption)
                //                                    .foregroundColor(.blue)
                //                            }
                //                        }
                //                    }
                //                }
                //                .padding()
                
                //🔹 Custom Date Picker with Total Expenses - optional
                //                Button(action: { showDatePicker.toggle() }) {
                //                    HStack {
                //                        Text(selectedDate, format: .dateTime.day().month().year())
                //                            .font(.headline)
                //                        Spacer()
                //                        Text("\(dailyTotals[selectedDate] ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                //                            .foregroundColor(.blue)
                //                            .font(.headline)
                //                    }
                //                    .padding()
                //                    .frame(height: 44)
                //                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                //                }
                //                .padding()
                //                .sheet(isPresented: $showDatePicker) {
                //                    VStack {
                //                        Text("Select a Date")
                //                            .font(.title2)
                //                            .padding()
                //
                //                        List {
                //                            ForEach(Array(dailyTotals.keys.sorted()), id: \.self) { date in
                //                                Button(action: {
                //                                    selectedDate = date
                //                                    showDatePicker = false
                //                                }) {
                //                                    HStack {
                //                                        Text(date, format: .dateTime.day().month().year())
                //                                        Spacer()
                //                                        Text("\(dailyTotals[date]!, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                //                                            .foregroundColor(.blue)
                //                                    }
                //                                    .padding(.vertical, 5)
                //                                }
                //                            }
                //                        }
                //                        .frame(maxHeight: 300)
                //                    }
                //                    .presentationDetents([.medium, .large])
                //                }
                
                // 🔹 Add Date Picker for filtering
                //                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                //                    .datePickerStyle(.compact)
                //                    .padding(.leading)
                
                List {
                    let filteredExpenses = expenses.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
                    
                    if filteredExpenses.isEmpty {
                        Text("No expenses for this date.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(filteredExpenses) { item in
                            Section(
                                header: Text(
                                    item.date,
                                    format: .dateTime
                                        .day()
                                        .month()
                                        .year()
                                )
                            ) {
                                HStack {
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
                                    Button(action: {
                                        expenseToDelete = item.id
                                        showAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        selectedExpense = item
                                    }) {
                                        Image(systemName: "pencil")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        // 🔹 Display Total Expense for Selected Date
                        Text("Daily Expenses: \(totalSelectedExpenses,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))"
                        )
                        .font(.headline)
                    }
                }
            }
        }
        .alert("Confirm Deletion", isPresented: $showAlert) {
            Button("Delete", role: .destructive) {
                if let id = expenseToDelete {
                    onDelete(id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this expense?")
        }
        .sheet(item: $selectedExpense) { expenseToEdit in
            EditView(expense: expenseToEdit, onUpdate: updateExpense)
        }
        
        //        NavigationStack {
        //            List{
        //                let groupedItems = Dictionary(grouping: expenses, by: {$0.date})
        //
        //                ForEach(groupedItems.keys.sorted(), id: \.self){ date in
        //                    Section(header: Text(date, format: .dateTime.day().month().year())){
        //                        ForEach(groupedItems[date]!){ item in
        //                            HStack{
        //                                VStack(alignment: .leading) {
        //                                    Text(item.title)
        //                                        .font(.headline)
        //                                    if let note = item.note, !note.isEmpty {
        //                                        Text(note)
        //                                            .font(.footnote)
        //                                    }
        //                                }
        //                                Spacer()
        //                                Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        //                                Divider()
        //                                //Note: By default list will trigger the button if tapped, to solve add .buttonStyle(PlainButtonStyle()) modifier
        //                                Button(action:{
        //                                    //                                    onDelete(item.id)
        //                                    expenseToDelete = item.id
        //                                    showAlert = true
        //                                    //                                    dismiss()
        //
        //                                }){
        //                                    Image(systemName: "trash")
        //                                        .foregroundStyle(.red)
        //                                }
        //                                .buttonStyle(PlainButtonStyle())
        //                                Button(action: {
        //                                    selectedExpense = item
        //                                }){
        //                                    Image(systemName: "pencil")
        //                                }
        //                                .buttonStyle(PlainButtonStyle())
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //        .alert("Confirm Deletion", isPresented: $showAlert){
        //            Button("Delete", role: .destructive){
        //                if let id = expenseToDelete{
        //                    onDelete(id)
        //                    print("Delete item with id \(id)")
        //                    dismiss()
        //                }
        //            }
        //            Button("Cancel", role: .cancel){}
        //        } message: {
        //            Text("Are you sure want to delete this expense?")
        //        }
        //        .sheet(item: $selectedExpense){ expenseToEdit in
        //            EditView(expense: expenseToEdit, onUpdate: updateExpense)
        //        }
    }
    
    private func updateExpense(updatedExpense: ExpenseItem){
        onUpdate(updatedExpense)
    }
    
    private var totalExpenses: Double {
        let total = expenses.reduce(0){ $0 + $1.amount}
        return total
    }
    
    private var totalSelectedExpenses: Double {
        expenses
            .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .reduce(0) { $0 + $1.amount }
    }
    
    //daily total expense based on date
    // 🔹 Dictionary to Store Total Expenses Per Date
    private var dailyTotals: [Date: Int] {
        var totals: [Date: Int] = [:]
        for expense in expenses {
            let normalizedDate = Calendar.current.startOfDay(for: expense.date)
            //totals[normalizedDate, default: 0] += expense.amount
            //for customize the amount
            let currentTotal = totals[normalizedDate] ?? 0
            totals[normalizedDate] = (currentTotal + Int(expense.amount)) / 1_000
        }
        return totals
    }
    
    // 🔹 Get All Days in the Current Month
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return [] }
        
        return range.compactMap { day -> Date? in
            let components = calendar.dateComponents([.year, .month], from: currentMonth)
            return calendar.date(from: DateComponents(year: components.year, month: components.month, day: day))
        }
    }
    
    // 🔹 Change the Displayed Month
    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
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
