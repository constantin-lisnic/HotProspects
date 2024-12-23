//
//  ProspectView.swift
//  HotProspects
//
//  Created by Constantin Lisnic on 23/12/2024.
//

import CodeScanner
import SwiftData
import SwiftUI
import UserNotifications

struct ProspectView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }

    @Environment(\.modelContext) var modelContext
    @Query var prospects: [Prospect]
    @State private var isShowingScanner = false
    @State private var selectedProspects = Set<Prospect>()

    @State private var sortOrder = [
        SortDescriptor(\Prospect.name),
        SortDescriptor(\Prospect.createdAt),
    ]

    var filter: FilterType
    var sortedProspects: [Prospect] {
        prospects.sorted(using: sortOrder)
    }

    var title: String {
        switch filter {
        case .none: "Everyone"
        case .contacted: "Contacted people"
        case .uncontacted: "Uncontacted prople"
        }
    }

    init(filter: FilterType) {
        self.filter = filter

        if filter != .none {
            let showContactedOnly = filter == .contacted

            _prospects = Query(
                filter: #Predicate {
                    $0.isContacted == showContactedOnly
                })
        }
    }

    var body: some View {
        NavigationStack {
            List(sortedProspects, selection: $selectedProspects) { prospect in
                NavigationLink {
                    EditView(
                        prospect: prospect,
                        selectedProspects: $selectedProspects)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.email)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if prospect.isContacted {
                            Image(
                                systemName:
                                    "person.crop.circle.fill.badge.checkmark"
                            )
                            .foregroundStyle(.green)
                        }
                    }
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(prospect)
                    }

                    if prospect.isContacted {
                        Button(
                            "Mark Uncontacted",
                            systemImage: "person.crop.circle.badge.xmark"
                        ) {
                            prospect.isContacted.toggle()
                        }
                        .tint(.blue)
                    } else {
                        Button(
                            "Mark Contacted",
                            systemImage:
                                "person.crop.circle.fill.badge.checkmark"
                        ) {
                            prospect.isContacted.toggle()
                        }
                        .tint(.green)

                        Button("Remind Me", systemImage: "bell") {
                            addNotification(for: prospect)
                        }
                        .tint(.orange)
                    }
                }
                .tag(prospect)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        isShowingScanner = true
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
                        Picker("Sort", selection: $sortOrder) {
                            Text("Sort by Name")
                                .tag([
                                    SortDescriptor(\Prospect.name),
                                    SortDescriptor(\Prospect.createdAt),
                                ])

                            Text("Sort by Date")
                                .tag([
                                    SortDescriptor(\Prospect.createdAt),
                                    SortDescriptor(\Prospect.name),
                                ])
                        }
                    }
                }

                if !selectedProspects.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete Selected", action: delete)
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData: "Constantin Lisnic\nconstantin@lisnic.dev",
                    completion: handleScan)
            }
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false

        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let newProspect = Prospect(
                name: details[0], email: details[1], isContacted: false)

            modelContext.insert(newProspect)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    func delete() {
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
    }

    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()

            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.email
            content.sound = UNNotificationSound.default

            // uncomment this when shipping the app
            //
            //            var dateComponents = DateComponents()
            //            dateComponents.hour = 9
            //            let trigger = UNCalendarNotificationTrigger(
            //                dateMatching: dateComponents, repeats: false)

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(
                identifier: UUID().uuidString, content: content,
                trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) {
                    success, error in
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

#Preview {
    ProspectView(filter: .none)
        .modelContainer(for: Prospect.self)
}
