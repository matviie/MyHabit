import SwiftUI


struct EditHabit: View {
    @EnvironmentObject var habitModel: HabitsViewModel
    
    @Environment(\.self) var env
    
    @State private var isEditing = false
    
    var habitColorPicker: some View {
        HStack(spacing: 0) {
            ForEach(1...6, id: \.self) { index in
                let color = "Card-\(index)"
                Circle()
                    .fill(Color(color))
                    .frame(width: 40, height: 40)
                    .overlay(content: {
                        if color == habitModel.habitColor {
                            Image(systemName: "checkmark")
                                .font(.title2.bold())
                        }
                    })
                    .onTapGesture {
                        withAnimation {
                            habitModel.habitColor = color
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isEditing)
            }
        }
        .padding(.vertical)
        .padding(.horizontal)
    }
    
    var frequencySelection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Frequency")
                .font(.callout.bold())
                .padding(.horizontal)
            
            let weekDays = Array(Calendar.current.weekdaySymbols[1...]) + [Calendar.current.weekdaySymbols[0]]
            
            HStack(spacing: 10) {
                ForEach(weekDays, id: \.self) { day in
                    let index = habitModel.weekDays.firstIndex { value in
                        return value == day
                    } ?? -1
                    
                    Text(day.prefix(2))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(index != -1 ? Color(habitModel.habitColor) : Color("TFBG").opacity(0.4))
                        }
                        .onTapGesture {
                            withAnimation {
                                if index != -1 {
                                    habitModel.weekDays.remove(at: index)
                                } else {
                                    habitModel.weekDays.append(day)
                                }
                            }
                        }
                        .disabled(!isEditing)
                }
            }
            .padding(.top, 15)
            .padding(.horizontal)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    
                    TextField("Title", text: $habitModel.title)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .disabled(!isEditing)
                        .padding(.horizontal)
                    
                    habitColorPicker
                    
                    Divider()
                    
                    frequencySelection
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Remainder")
                                .fontWeight(.semibold)
                            
                            Text("Just notification")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle(isOn: $habitModel.isRemainderOn) {}
                            .labelsHidden()
                            .disabled(!isEditing)
                    }
                    .opacity(habitModel.notificationAccess ? 1 : 0)
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        Label {
                            Text(habitModel.notificationDate.formatted(date: .omitted, time: .shortened))
                        } icon: {
                            Image(systemName: "clock")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .onTapGesture {
                            withAnimation {
                                habitModel.showTimePicker.toggle()
                            }
                        }
                        
                        TextField("Remainder Text", text: $habitModel.remainderText)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color("TFBG").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .disabled(!isEditing)
                    }
                    .padding(.horizontal)
                    .frame(height: habitModel.isRemainderOn ? nil : 0)
                    .opacity(habitModel.isRemainderOn ? 1 : 0)
                    .opacity(habitModel.notificationAccess ? 1 : 0)
                    
                    // MARK: відображення календаря
                    CalendarView(dateInterval: .init(start: .distantPast, end: Date.now), completedDates: $habitModel.completedDates, color: habitModel.habitColor)

                }
                .animation(.easeInOut, value: habitModel.isRemainderOn)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(habitModel.title)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            env.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle")
                        }

                        if isEditing {
                            Button {
                                if habitModel.deleteHabit(context: env.managedObjectContext) {
                                    env.dismiss()
                                }
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isEditing ? "Save" : "Edit") {
                            if isEditing {
                                Task {
                                    if await habitModel.saveHabit(context: env.managedObjectContext) {
                                        env.dismiss()
                                    }
                                }
                            } else {
                                isEditing.toggle()
                            }
                        }
                        .disabled(!habitModel.doneStatus())
                        .opacity(habitModel.doneStatus() ? 1 : 0.6)
                    }
                }

            }
            
        }
        .overlay {
            if habitModel.showTimePicker {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                habitModel.showTimePicker.toggle()
                            }
                        }
                    
                    DatePicker("", selection: $habitModel.notificationDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("TFBG"))
                        }
                        .padding()
                }
            }
        }
    }
}


#Preview {
    EditHabit()
        .environmentObject(HabitsViewModel())
        .preferredColorScheme(.dark)
}
