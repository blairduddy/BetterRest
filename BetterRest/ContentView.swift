//
//  ContentView.swift
//  BetterRest
//
//  Created by Blair Duddy on 2023-05-23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var sleepTime = Date()
    
    let coffeeOptions = Array(1...20)
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Something went wrong."
        }
        showingAlert = true
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Wake up time:")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity)
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section{
                    Text("Daily coffee intake")
                        .font(.headline)
                    //replace with picker
                    //Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    Picker("Number of Coffees", selection: $coffeeAmount) {
                        ForEach(coffeeOptions, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
                
                VStack(alignment: .center, spacing: 10){
                    Text("Your ideal bedtime is:")
                    Text("\(sleepTime.formatted(date: .omitted, time: .shortened))")
                        .font(.largeTitle)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("BetterRest")
        }
    }
}


    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
