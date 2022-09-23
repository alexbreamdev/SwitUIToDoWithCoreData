//
//  ContentView.swift
//  SwitUIToDoWithCoreData
//
//  Created by Oleksii Leshchenko on 23.09.2022.
//

import SwiftUI
import CoreData

enum Priority: String, Identifiable, CaseIterable {
    var id: UUID {
        return UUID()
    }
    
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

extension Priority {
    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

struct ContentView: View {
    @State private var title: String = ""
    @State private var selectedPriority: Priority = .medium
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allTasks: FetchedResults<Task>
    
    
    private func saveTask() {
        do {
            let task = Task(context: viewContext)
            task.title = title
            task.priority = selectedPriority.rawValue
            task.dateCreated = Date()
            try viewContext.save()
        } catch {
            print("Couldn't save to database \(error)")
        }
    }
    
    private func updateTask(task: Task) {
        task.isFavourite = !task.isFavourite
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteTask(at offset: IndexSet) {
        offset.forEach { index in
            let task = allTasks[index]
            viewContext.delete(task)
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func styleForPriority(_ value: String) -> Color {
        switch value {
        case "Low":
            return Color.green
        case "Medium":
            return Color.yellow
        case "High":
            return Color.red
        default: return Color.primary
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter title", text: $title)
                    .textFieldStyle(.roundedBorder)
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(Priority.allCases) { priority in
                        Text(priority.title).tag(priority)
                    }
                    
                }
                .pickerStyle(.segmented)
                
                Button {
                    saveTask()
                } label: {
                    Text("Save")
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                List {
                    ForEach(allTasks) { task in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(styleForPriority(task.priority!))
                                .frame(width: 15, height: 15)
                            Spacer().frame(width: 20)
                            Text(task.title ?? "No title")
                            Spacer()
                            Image(systemName: task.isFavourite ? "heart.fill" : "heart")
                                .foregroundColor(Color(uiColor: .systemPink))
                                .onTapGesture {
                                    updateTask(task: task)
                                }
                        }
                        
                    }
                    .onDelete(perform: deleteTask)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("All Tasks")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = CoreDataManager.shared.persistentContainer
        
        ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
        
    }
}
