//
//  EditView.swift
//  HotProspects
//
//  Created by Constantin Lisnic on 24/12/2024.
//

import SwiftUI

struct EditView: View {
    var prospect: Prospect
    @Binding var selectedProspects: Set<Prospect>

    @State private var name: String
    @State private var email: String

    init(
        prospect: Prospect, selectedProspects: Binding<Set<Prospect>>
    ) {
        self.prospect = prospect
        _selectedProspects = selectedProspects

        _name = State(initialValue: prospect.name)
        _email = State(initialValue: prospect.email)
    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Email Address", text: $email)

            Section("Created at") {
                Text(
                    prospect.createdAt.formatted(
                        date: .abbreviated, time: .complete))
            }

        }
        .onAppear {
            selectedProspects = Set()
        }
        .onDisappear {
            prospect.name = name
            prospect.email = email
        }
    }
}

#Preview {
    @Previewable @State var testSelectedProspects = Set<Prospect>()

    EditView(
        prospect: Prospect(
            name: "Constantine", email: "Lisnic", isContacted: false),
        selectedProspects: $testSelectedProspects
    )
}
