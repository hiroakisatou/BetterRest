//
//  ContentView.swift
//  BetterRest
//
//  Created by tsu-na-gu on 2026/03/25.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
              VStack(alignment: .leading , spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                        .padding(.bottom, 10)
                    DatePicker("Please enter a date", selection: $wakeUp, in: Date.now..., displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                        .padding(.bottom, 10)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker("Number of cups of coffee", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) { index in
                            Text(index == 1 ? "1 cup" :"\(index) cups(s)")
                        }
                    }
                }
                VStack {
                    HStack {
                        Spacer()
                        Button("Calculate") {
                            calculateBedtime()
                        }
                        .font(.title)
                        .padding(10)
                        .background(.black.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {
                    showingAlert = false
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prection = try model.prediction(wake: Double(hour + minute),
                                                estimatedSleep: sleepAmount,
                                                coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prection.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            showingAlert = true
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculation your bedtime."
            showingAlert = true
        }
    }
}

#Preview {
    ContentView()
}
