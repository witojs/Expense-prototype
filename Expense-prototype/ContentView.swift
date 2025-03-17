//
//  ContentView.swift
//  Expense-prototype
//
//  Created by Wito Irawan on 14/03/25.
//

import SwiftUI
import Charts

//structur data dari rincian item expense
struct ExpenseItem: Identifiable, Codable{
    var id = UUID()
    let title: String
    let category: String
    let amount: Double
    let date: Date
    let note: String?
}

//for chart
struct CategoryTotal{
    let category: String
    let total: Double
}

//observable class memungkinkan class digunakan sebagai state, didSet & init untuk menyimpan data ke UserDefaults secara otomatis
@Observable class Expenses {
    var items = [ExpenseItem](){
        didSet{
            if let encoded = try? JSONEncoder().encode(items){
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init(){
        if let savedItems = UserDefaults.standard.data(forKey: "Items"){
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems){
                items = decodedItems
                return
            }
        }
        //if getting the data failed
        items = []
    }
}
//Todo 1: Buat data class untuk user income, total expense
//Todo 2: Buat fitur edit transaction
//Todo 3: ketika user klik detail ke halaman report nya - done
//Todo 4: Jika user belum input biaya, munculkan Keterangan
//todo 5: User bisa ascending / descending report daily nya
//todo 6: Buat Categori untuk memfasilitasi user jika tidak ada biaya harian
//todo 7: fitur streak jika user belum input untuk hari baru, otomatis jadi 0 dan baru berubah jika user menginput daily expense
struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    
    //untuk fitur streak
    @State private var currentStreak = 0
    
    let categoryTotalPlaceholder = [
        CategoryTotal(category: "Personal", total: 4.5),
        CategoryTotal(category: "Business", total: 3.5),
        CategoryTotal(category: "Travel", total: 2.5),
    ]

    var body: some View {
        NavigationStack{
            VStack {
                if expenses.items.isEmpty{
                    Chart(categoryTotalPlaceholder, id: \.category){ category in
                        SectorMark(
                            angle: .value("CategoryTotal", category.total),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(4)
                        .foregroundStyle(Color.gray)
                        .opacity(0.8)
                    }
                    .frame(height: 200)
                    .brightness(0.2)
                    .padding()
                } else {
                    ZStack {
                        Chart(categoryTotals, id: \.category){ category in
                            SectorMark(
                                angle: .value("CategoryTotal", category.total),
                                innerRadius: .ratio(0.618),
                                angularInset: 1.5
                            )
                            .cornerRadius(4)
                            .foregroundStyle(by: .value("Category", category.category))
                        }
                        .frame(height: 200)
                        .chartXAxis(.hidden)
                        .padding()
                        
                        VStack {
                            Text("Total:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("\(Decimal(totalExpenses), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                .font(.footnote)
                        }
                        .offset(y: -10)
                    }
                }
            }
            VStack(alignment: .leading) {
                Text("Your Streak is \(currentStreak)")
                    .padding()
                Text("Here's What you spent:")
                    .font(.headline)
                    .padding(.leading)
                List{
                    ForEach(groupedExpenses.keys.sorted(by: { groupedExpenses[$0]!.total > groupedExpenses[$1]!.total }), id: \.self){ category in
//                        Section{
                            HStack {
                                Text(category)
                                    .font(.headline)
                                Spacer()
                                NavigationLink(destination: DetailView(category: category, expenses: groupedExpenses[category]!.items, onDelete: deleteItem, onUpdate: updateItem)){
                                    Text("Total: \(Decimal(groupedExpenses[category]!.total), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))")
                                }
                            }
//                        }
                    }
                }
            }
            .padding(.top)
            .navigationTitle("Expense Prototype")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("Add"){
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense){
                AddView(expense: expenses)
            }
            .onAppear{
                currentStreak = calculateStreak(from: expenses.items)
            }
        }
    }

    // Group expenses by category and calculate total amounts
    private var groupedExpenses: [String: (total: Double, items: [ExpenseItem])] {
        var grouped: [String: (total: Double, items: [ExpenseItem])] = [:]
        
        for expense in expenses.items {
                if grouped[expense.category] == nil {
                    grouped[expense.category] = (total: 0.0, items: [])
                }
                grouped[expense.category]!.total += expense.amount
                grouped[expense.category]!.items.append(expense)
            }
        return grouped
    }
    
    //for showing total expenses
    private var totalExpenses: Double {
        let total = expenses.items.reduce(0){ $0 + $1.amount}
        return total
    }
    
    //for chart data
    private var categoryTotals: [CategoryTotal]{
        groupedExpenses.map{(key, value) in
            CategoryTotal(category: key, total: value.total)
        }
    }
    
    //for delete data in DetailView
    private func deleteItem(id: UUID){
        if let index = expenses.items.firstIndex(where: {$0.id == id}){
            expenses.items.remove(at: index)
        }
    }
    
    //for update data
    private func updateItem(updatedExpense: ExpenseItem){
        if let index = expenses.items.firstIndex(where: {$0.id == updatedExpense.id}){
            expenses.items[index] = updatedExpense
        }
    }
    
    //new calculate streak:
    private func calculateStreak(from items: [ExpenseItem]) -> Int {
        let today = Calendar.current.startOfDay(for: Date()) // Normalize today to the start of the day
        var currentStreak = 0

        // Sort items by date
        let sortedItems = items.sorted { $0.date < $1.date }
        
        // Create a set of dates for quick lookup
        var dateSet: Set<Date> = []
        for item in sortedItems {
            let inputDate = Calendar.current.startOfDay(for: item.date)
            dateSet.insert(inputDate)
        }

        // Start checking from today and go backwards
        var dateToCheck = today
        while dateSet.contains(dateToCheck) {
            currentStreak += 1
            // Move to the previous day
            dateToCheck = Calendar.current.date(byAdding: .day, value: -1, to: dateToCheck)!
        }
        print("Current streak is \(currentStreak)")
        return currentStreak
    }
    
}

#Preview {
    ContentView()
    
}

/* groupedExpense Data
 [
 "Personal": (total: 20238000.0,
    items: [Expense_prototype.ExpenseItem(id: 75FDE79E-D7F8-4C23-842D-F7D3938C5679, title: "Belanja pagi", category: "Personal", amount: 200000.0, date: 2025-03-14 15:18:32 +0000, note: Optional("Beli Galon standford")), Expense_prototype.ExpenseItem(id: D468CFD4-E84A-4E66-84D1-0B8EE0E63835, title: "Makan", category: "Personal", amount: 15000.0, date: 2025-03-14 15:21:38 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: 6703AC10-228D-4E2B-8CA9-4DEAC5D2C86C, title: "Sewa Gudang", category: "Personal", amount: 5000000.0, date: 2025-03-13 15:42:00 +0000, note: Optional("Sewa gudang 2025")), Expense_prototype.ExpenseItem(id: 4DD765BE-BB3E-43FE-91B6-B36CA0342568, title: "Beli iPhone", category: "Personal", amount: 15000000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("iPhone 16")), Expense_prototype.ExpenseItem(id: F5D4CCFB-DB18-4A24-9E58-7FC57A992876, title: "Beli chicki", category: "Personal", amount: 15000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: CA580AD6-53F2-443B-926B-6134991143CC, title: "Beli pocari", category: "Personal", amount: 8000.0, date: 2025-03-14 17:00:00 +0000, note: Optional(""))]
    ),
     "Travel": (total: 9164000.0,
        items: [Expense_prototype.ExpenseItem(id: B49349E6-462A-4DF4-9D23-33F943A7A840, title: "Beli tiket pesawat", category: "Travel", amount: 1200000.0, date: 2025-03-14 15:35:08 +0000, note: Optional("Ke Batam")), Expense_prototype.ExpenseItem(id: E0BABD36-C9AA-47BD-A63E-EEC5B5F676DE, title: "Tiket pesawat", category: "Travel", amount: 7000000.0, date: 2025-03-12 15:45:16 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: 8D199568-EFF9-4903-AEE2-72AE143299A9, title: "Nonton bioskop", category: "Travel", amount: 65000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("XXI MB2")), Expense_prototype.ExpenseItem(id: 407D912F-157D-4ADC-A12D-C297DAAD439B, title: "Beli tiket ke Singapore", category: "Travel", amount: 899000.0, date: 2025-03-14 17:00:00 +0000, note: Optional(""))]
     ),
     "Business": (total: 500000.0,
        items: [Expense_prototype.ExpenseItem(id: 1032A107-04CD-42FE-8206-B390C99173B4, title: "Entertain", category: "Business", amount: 500000.0, date: 2025-03-14 15:19:14 +0000, note: Optional("Karaoke"))]
     )
 ]
 */

/*
 [Expense_prototype.ExpenseItem(id: E0BABD36-C9AA-47BD-A63E-EEC5B5F676DE, title: "Tiket pesawat", category: "Travel", amount: 7000000.0, date: 2025-03-12 15:45:16 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: 6703AC10-228D-4E2B-8CA9-4DEAC5D2C86C, title: "Sewa Gudang", category: "Personal", amount: 5000000.0, date: 2025-03-13 15:42:00 +0000, note: Optional("Sewa gudang 2025")), Expense_prototype.ExpenseItem(id: 75FDE79E-D7F8-4C23-842D-F7D3938C5679, title: "Belanja pagi", category: "Personal", amount: 200000.0, date: 2025-03-14 15:18:32 +0000, note: Optional("Beli Galon standford")), Expense_prototype.ExpenseItem(id: 1032A107-04CD-42FE-8206-B390C99173B4, title: "Entertain", category: "Business", amount: 500000.0, date: 2025-03-14 15:19:14 +0000, note: Optional("Karaoke")), Expense_prototype.ExpenseItem(id: D468CFD4-E84A-4E66-84D1-0B8EE0E63835, title: "Makan", category: "Personal", amount: 15000.0, date: 2025-03-14 15:21:38 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: B49349E6-462A-4DF4-9D23-33F943A7A840, title: "Beli tiket pesawat", category: "Travel", amount: 1200000.0, date: 2025-03-14 15:35:08 +0000, note: Optional("Ke Batam")), Expense_prototype.ExpenseItem(id: 4DD765BE-BB3E-43FE-91B6-B36CA0342568, title: "Beli iPhone", category: "Personal", amount: 15000000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("iPhone 16")), Expense_prototype.ExpenseItem(id: F5D4CCFB-DB18-4A24-9E58-7FC57A992876, title: "Beli chicki", category: "Personal", amount: 15000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: CA580AD6-53F2-443B-926B-6134991143CC, title: "Beli pocari", category: "Personal", amount: 8000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: 8D199568-EFF9-4903-AEE2-72AE143299A9, title: "Nonton bioskop", category: "Travel", amount: 65000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("XXI MB2")), Expense_prototype.ExpenseItem(id: 407D912F-157D-4ADC-A12D-C297DAAD439B, title: "Beli tiket ke Singapore", category: "Travel", amount: 899000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: 50E8EF79-DECD-4851-9CC0-E292A38DF693, title: "Advertising in YouTube", category: "Business", amount: 6799000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: 72201B4C-FC21-47A2-A0FE-D52F22E634BE, title: "Join Apple developer academy", category: "Education", amount: 18000000.0, date: 2025-03-14 17:00:00 +0000, note: Optional("Di Infinite Learning")), Expense_prototype.ExpenseItem(id: 2BDA0E59-6E79-49E6-831B-7F80DE2CBC82, title: "Beli makan", category: "Personal", amount: 15000.0, date: 2025-03-15 17:00:00 +0000, note: Optional("")), Expense_prototype.ExpenseItem(id: 55462EAF-9BBB-4B88-8FBD-658B7D2AEC3C, title: "Course udemy", category: "Education", amount: 90000.0, date: 2025-03-15 17:00:00 +0000, note: Optional(""))]
 */
